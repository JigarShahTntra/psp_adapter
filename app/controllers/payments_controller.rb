class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    payload = params.require(:payment).permit!.to_h
    idempotency_key = request.headers["Idempotency-Key"] || SecureRandom.uuid

    payment = Payment.find_or_create_by(idempotency_key: idempotency_key) do |p|
      p.txn_id = SecureRandom.uuid
      p.amount_cents = (payload['amount'].to_f * 100).to_i
      p.currency = payload['currency'] || 'USD'
      p.status = 'pending'
      p.metadata = payload['metadata'] || {}
    end

    # choose PSP (for MVP use default)
    psp_id = payload.dig('metadata', 'preferred_psp') || Adapter::AdapterFactory.default_psp
    adapter = Adapter::AdapterFactory.for(psp_id)
    result = adapter.authorize(payment.to_canonical_hash.merge('metadata' => payment.metadata))

    if result['status'] == 'approved' || result['status'] == 'authorized'
      payment.update!(status: 'approved', psp_id: psp_id, psp_txn_id: result['psp_txn_id'], metadata: payment.metadata.merge('psp_response' => result))
      render json: { txn_id: payment.txn_id, status: 'approved' }, status: :ok
    else
      payment.update!(status: 'declined', psp_id: psp_id, metadata: payment.metadata.merge('psp_response' => result))
      render json: { txn_id: payment.txn_id, status: 'declined', reason: result['error'] || result['status'] }, status: :unprocessable_entity
    end
  end
end

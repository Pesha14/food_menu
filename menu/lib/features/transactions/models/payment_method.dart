/// Payment method IDs are configured per-company on the backend and
/// normally listed via GET /api/v1/payment -- but that endpoint is
/// restricted to COMPANY_ADMIN/HR roles, and staff log in as USER, so the
/// POS app can't fetch the list itself.
///
/// Cash (6) is hardcoded here to match the guide's example. Raise this
/// with the backend team: either open GET /payment to the USER role, or
/// have them confirm/document the fixed set of IDs the POS should use.
class PaymentMethod {
  PaymentMethod._();

  static const int cash = 6;
}

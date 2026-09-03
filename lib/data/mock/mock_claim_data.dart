import '../models/product.dart';

/// Doc 134 — what an agent needs in front of a client who is asking
/// "can I claim for this, and what do you need from me?".
///
/// The *benefits* and *exclusions* already live on the product; what was
/// missing is the procedural half — the documents to gather and the route
/// to file. Both are UI-only mock: Core owns claim rules.
class ClaimGuide {
  const ClaimGuide({
    required this.documents,
    required this.steps,
    required this.turnaround,
  });

  /// What the claimant has to bring. The list an agent reads out.
  final List<String> documents;

  /// How a claim is filed, in order.
  final List<String> steps;

  /// Indicative processing time, phrased as an expectation, not a promise.
  final String turnaround;
}

class MockClaimData {
  MockClaimData._();

  /// Documents differ by what is being claimed, which tracks the product
  /// category closely enough to key on it — a per-product override can be
  /// added later without changing any screen.
  static const _byCategory = <ProductCategory, ClaimGuide>{
    ProductCategory.health: ClaimGuide(
      documents: [
        'Completed claim form, signed by the policyholder',
        'NRC or passport copy of the insured',
        'Original hospital bills and receipts',
        'Discharge summary and doctor\'s diagnosis',
        'Prescription and pharmacy receipts, where claimed',
        'Bank account details for the payout',
      ],
      steps: [
        'Collect the documents above from the client.',
        'Submit them to the nearest KBZ Life branch, or hand them to the claims desk through your branch manager.',
        'Core records the claim and issues a claim reference.',
        'Track progress with the claim reference; the client is notified of the outcome.',
      ],
      turnaround: 'Usually 7–14 working days once documents are complete',
    ),
    ProductCategory.protection: ClaimGuide(
      documents: [
        'Completed claim form, signed by the claimant',
        'NRC or passport copy of the insured and the claimant',
        'Police report, for an accident claim',
        'Medical report or death certificate, as applicable',
        'Proof of relationship for a beneficiary claim',
        'Bank account details for the payout',
      ],
      steps: [
        'Notify KBZ Life as soon as the incident is known — do not wait for the paperwork.',
        'Collect the documents above from the claimant.',
        'Submit them to the nearest KBZ Life branch.',
        'Core assesses the claim and issues the decision to the claimant.',
      ],
      turnaround: 'Usually 14–30 working days once documents are complete',
    ),
    ProductCategory.saving: ClaimGuide(
      documents: [
        'Completed claim or maturity form, signed by the policyholder',
        'Original policy document',
        'NRC or passport copy of the policyholder',
        'Death certificate and proof of relationship, for a death claim',
        'Bank account details for the payout',
      ],
      steps: [
        'Confirm with the client whether this is a maturity, a surrender or a death claim — the form differs.',
        'Collect the documents above.',
        'Submit them to the nearest KBZ Life branch.',
        'Core verifies the policy and releases the payment.',
      ],
      turnaround: 'Usually 7–14 working days once documents are complete',
    ),
  };

  static ClaimGuide forCategory(ProductCategory category) =>
      _byCategory[category]!;
}

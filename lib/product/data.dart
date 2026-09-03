import 'package:flutter/material.dart';

import 'model.dart';

final List<ProductItem> products = [
  ProductItem(
    id: '1',
    title: 'Universal Life',
    category: 'Saving',
    shortDescription: 'Flexible savings with lifelong protection.',
    fullDescription:
        'Universal Life combines life cover with a savings account you can top up. Cash value grows with declared rates; the death benefit pays the sum insured to beneficiaries.',
    icon: Icons.shield_outlined,
    imageAsset: 'assets/products/universal_life.jpeg',
    minAge: '16 years',
    maxAge: '65 years',
    policyTerm: 'Up to Age 80',
    minPremium: 'MMK 50,000 / month',
    benefits: [
      'Guaranteed minimum interest rate applied annually',
      'Death benefit pays sum insured to beneficiaries',
      'Total Permanent Disability coverage until age 65',
      'Partial withdrawals permitted after 60 days',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.person_outline,
        title: 'Individuals',
        description:
            'Anyone aged 16 to 65 looking to save while staying covered.',
      ),
      DesignedForItem(
        icon: Icons.family_restroom_outlined,
        title: 'Families',
        description:
            'Spouse, children, or dependents can be named as beneficiaries.',
      ),
      DesignedForItem(
        icon: Icons.business_outlined,
        title: 'Employers',
        description:
            'Useful as a staff benefit conversation — not a group/entity proposal.',
      ),
    ],
    whyBuy: [
      'Flexible premiums and top-ups',
      'Lifelong protection option',
      'Cash value you can illustrate in a quote',
      'Clear Core product code for e-App',
    ],
  ),
  ProductItem(
    id: '2',
    title: 'Short Term Endowment',
    category: 'Saving',
    shortDescription: 'Save for a set term, then take the maturity benefit.',
    fullDescription:
        'Guaranteed financial security with systematic savings and life coverage benefits. Ideal for medium-term financial goals.',
    icon: Icons.savings_outlined,
    imageAsset: 'assets/products/education_icon.jpg',
    minAge: '18 years',
    maxAge: '60 years',
    policyTerm: '5 - 10 Years',
    minPremium: 'MMK 30,000 / month',
    benefits: [
      'Guaranteed maturity benefit at end of term',
      'Life coverage throughout the policy term',
      'Flexible premium payment options',
      'Tax benefits on premiums paid',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.savings_outlined,
        title: 'Savers',
        description:
            'People looking for guaranteed returns over a fixed period.',
      ),
      DesignedForItem(
        icon: Icons.flag_outlined,
        title: 'Goal Planners',
        description:
            'Those saving for specific financial goals like education or home.',
      ),
    ],
    whyBuy: [
      'Guaranteed returns at maturity',
      'Flexible term options (5, 7, or 10 years)',
      'Life coverage included',
      'Simple and transparent product',
    ],
  ),
  ProductItem(
    id: '3',
    title: 'Personal Accident',
    category: 'Protection',
    shortDescription:
        'Protects you with the payouts from 71 category of accidents.',
    fullDescription:
        'Comprehensive accident protection covering 71 categories of accidents with payout benefits for death, disability, and medical expenses.',
    icon: Icons.health_and_safety_outlined,
    imageAsset: 'assets/products/personal _accident.jpeg',
    minAge: '5 years',
    maxAge: '70 years',
    policyTerm: '1 Year (Renewable)',
    minPremium: 'MMK 10,000 / year',
    benefits: [
      'Coverage for 71 categories of accidents',
      'Death and permanent disability benefits',
      'Medical expense reimbursement',
      'Weekly indemnity for temporary disability',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.person_outline,
        title: 'Individuals',
        description:
            'Anyone seeking financial protection against accident risks.',
      ),
      DesignedForItem(
        icon: Icons.work_outline,
        title: 'Working Professionals',
        description: 'Those with active lifestyles or high-risk occupations.',
      ),
    ],
    whyBuy: [
      'Wide range of accident coverage',
      'Affordable premiums',
      'Quick claim settlement',
      'No medical examination required',
    ],
  ),
  ProductItem(
    id: '4',
    title: 'Credit Life',
    category: 'Protection',
    shortDescription: 'Clears the outstanding loan if the life assured dies.',
    fullDescription:
        'Provides financial protection by clearing outstanding loans in case of the policyholder\'s death, ensuring family members are not burdened with debt.',
    icon: Icons.account_balance_outlined,
    imageAsset: 'assets/products/single_premium_credit.jpeg',
    minAge: '18 years',
    maxAge: '65 years',
    policyTerm: 'Loan Term Duration',
    minPremium: 'Based on loan amount',
    benefits: [
      'Covers outstanding loan amount',
      'Reduces financial burden on family',
      'Group and individual options available',
      'Automatic coverage with loan disbursement',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.home_outlined,
        title: 'Home Loan Borrowers',
        description: 'Those with home loans seeking to protect their family.',
      ),
      DesignedForItem(
        icon: Icons.business_center_outlined,
        title: 'Business Loan Holders',
        description: 'Entrepreneurs with business loans.',
      ),
    ],
    whyBuy: [
      'Peace of mind for loan borrowers',
      'Family stays protected from debt',
      'Simple enrollment process',
      'Competitive premium rates',
    ],
  ),
  ProductItem(
    id: '5',
    title: 'Critical Illness',
    category: 'Health',
    shortDescription: 'Comprehensive guard against major medical expenses.',
    fullDescription:
        'Provides a lump-sum payout upon diagnosis of specified critical illnesses, helping cover medical expenses and loss of income during treatment.',
    icon: Icons.medical_services_outlined,
    imageAsset: 'assets/products/critical_illness.jpeg',
    minAge: '18 years',
    maxAge: '55 years',
    policyTerm: '1 Year (Renewable)',
    minPremium: 'MMK 25,000 / year',
    benefits: [
      'Lump-sum payout on critical illness diagnosis',
      'Coverage for 36+ critical illnesses',
      'No claim bonus for claim-free years',
      'Worldwide coverage',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.person_outline,
        title: 'Adults',
        description:
            'Anyone wanting financial protection against serious illnesses.',
      ),
      DesignedForItem(
        icon: Icons.family_restroom_outlined,
        title: 'Families',
        description: 'Heads of households seeking to protect family finances.',
      ),
    ],
    whyBuy: [
      'Financial safety during critical illness',
      'One-time payout for any purpose',
      'No restrictions on usage of funds',
      'Affordable protection',
    ],
  ),
  ProductItem(
    id: '6',
    title: 'Group Life',
    category: 'Business',
    shortDescription: 'Tailored group coverage for corporate employees.',
    fullDescription:
        'Comprehensive group insurance solution designed for corporations to provide life and health benefits to their employees.',
    icon: Icons.groups_outlined,
    imageAsset: 'assets/products/health_insurance.jpeg',
    minAge: '18 years',
    maxAge: '65 years',
    policyTerm: '1 Year (Corporate)',
    minPremium: 'Customized based on group size',
    benefits: [
      'Life coverage for all employees',
      'Accidental death and disability benefits',
      'Medical and hospitalization coverage',
      'Easy administration for HR teams',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.business_outlined,
        title: 'Corporations',
        description: 'Companies looking to provide employee benefits.',
      ),
      DesignedForItem(
        icon: Icons.groups_outlined,
        title: 'Organizations',
        description: 'Non-profits and institutions with employee groups.',
      ),
    ],
    whyBuy: [
      'Attract and retain talent',
      'Tax benefits for the company',
      'Simplified group enrollment',
      'Comprehensive coverage options',
    ],
  ),
  ProductItem(
    id: '7',
    title: 'Education Life',
    category: 'Saving',
    shortDescription: 'Secures your children\'s higher education future.',
    fullDescription:
        'A savings plan designed to ensure children\'s higher education is funded even in unexpected events, providing regular payouts during the education years.',
    icon: Icons.school_outlined,
    imageAsset: 'assets/products/education_icon.jpg',
    minAge: 'Parent: 18-50',
    maxAge: 'Child: 0-15',
    policyTerm: '10 - 18 Years',
    minPremium: 'MMK 20,000 / month',
    benefits: [
      'Regular payouts during education years',
      'Life coverage for the parent/policyholder',
      'Guaranteed maturity benefits',
      'Flexibility to adjust premium payments',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.person_outline,
        title: 'Parents',
        description: 'Parents wanting to secure their children\'s education.',
      ),
      DesignedForItem(
        icon: Icons.family_restroom_outlined,
        title: 'Guardians',
        description: 'Guardians planning for a child\'s future education.',
      ),
    ],
    whyBuy: [
      'Secures education funding',
      'Protection for the paying parent',
      'Flexible premium options',
      'Long-term savings with returns',
    ],
  ),
  ProductItem(
    id: '8',
    title: 'Travel Insurance',
    category: 'Travel',
    shortDescription: 'Comprehensive coverage for your journeys.',
    imageAsset: 'assets/products/travel.jpeg',
    fullDescription:
        'Protection for travelers covering trip cancellation, medical emergencies abroad, baggage loss, and travel delays.',
    icon: Icons.flight_outlined,
    minAge: '5 years',
    maxAge: '75 years',
    policyTerm: 'Per Trip / Annual',
    minPremium: 'MMK 5,000 / trip',
    benefits: [
      'Trip cancellation and delay coverage',
      'Emergency medical treatment abroad',
      'Baggage loss and delay protection',
      '24/7 global assistance hotline',
    ],
    designedFor: [
      DesignedForItem(
        icon: Icons.flight_outlined,
        title: 'Travelers',
        description: 'Anyone traveling domestically or internationally.',
      ),
      DesignedForItem(
        icon: Icons.business_center_outlined,
        title: 'Business Travelers',
        description: 'Professionals traveling frequently for work.',
      ),
    ],
    whyBuy: [
      'Peace of mind while traveling',
      'Wide range of coverage',
      'Affordable single-trip rates',
      'Quick claim process',
    ],
  ),
];

/// Town master (mock). The Proposal Required Field sheet marks Township,
/// District and State/Region as "Auto-populated based on the selected
/// Town", so the FA picks one town and three fields fill themselves —
/// four taps become one, which is the whole reason the address block can
/// stay inside a single sub-sheet.
class TownEntry {
  const TownEntry(this.town, this.township, this.district, this.stateRegion);
  final String town;
  final String township;
  final String district;
  final String stateRegion;
}

const kTownMaster = <TownEntry>[
  TownEntry('Hlaing', 'Hlaing', 'West Yangon', 'Yangon Region'),
  TownEntry('Kamayut', 'Kamayut', 'West Yangon', 'Yangon Region'),
  TownEntry('Bahan', 'Bahan', 'East Yangon', 'Yangon Region'),
  TownEntry('Thingangyun', 'Thingangyun', 'East Yangon', 'Yangon Region'),
  TownEntry('Insein', 'Insein', 'North Yangon', 'Yangon Region'),
  TownEntry('Chanmyathazi', 'Chanmyathazi', 'Mandalay', 'Mandalay Region'),
  TownEntry('Maha Aungmye', 'Maha Aungmye', 'Mandalay', 'Mandalay Region'),
  TownEntry('Pyigyitagon', 'Pyigyitagon', 'Mandalay', 'Mandalay Region'),
  TownEntry('Zabuthiri', 'Zabuthiri', 'Nay Pyi Taw', 'Nay Pyi Taw'),
  TownEntry('Taunggyi', 'Taunggyi', 'Taunggyi', 'Shan State'),
  TownEntry('Mawlamyine', 'Mawlamyine', 'Mawlamyine', 'Mon State'),
  TownEntry('Pathein', 'Pathein', 'Pathein', 'Ayeyarwady Region'),
  TownEntry('Bago', 'Bago', 'Bago', 'Bago Region'),
  TownEntry('Magway', 'Magway', 'Magway', 'Magway Region'),
  TownEntry('Monywa', 'Monywa', 'Monywa', 'Sagaing Region'),
];

/// Sales masters (mock) — Proposal tab dropdowns are all "selected from a
/// master list" in the sheet; there is no Core in this prototype.
const kSaleChannels = ['Agency', 'Bancassurance', 'Direct', 'Broker'];
const kSaleGroups = ['ADM1', 'ADM2', 'AADM1', 'SADM1', 'SAM1', 'AM1'];
const kSalePersons = [
  'Aung Kyaw Moe (FA-1042)',
  'Su Su Hlaing (FA-2210)',
  'Nay Lin Tun (FA-3388)',
];
const kSaleAttachments = ['Direct', 'Referral Partner', 'Roadshow', 'Branch'];

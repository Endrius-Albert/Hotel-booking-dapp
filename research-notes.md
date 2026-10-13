# Research Notes – Hotel Booking DApp

## 1. The Current Booking System

### How a booking works today

    Guest ──books & pays──▶ OTA (Booking.com / Expedia) ──pays out, minus commission──▶ Hotel

Most guests book through an Online Travel Agency (OTA). Depending on the payment model, the guest pays at the hotel, or the OTA charges the guest and pays the hotel later. Either way, the OTA sits in the middle: it controls how the hotel is shown, sets the payment rules and handles disputes.

### Who controls the market


Booking Holdings and Expedia Group control more than 85% of OTA hotel bookings in Europe, and almost 69% of those go through Booking Holdings alone (HOTREC, 2026). OTAs now account for 29.9% of all hotel bookings, up from 19.7% in 2013 (HOTREC, 2022, cited in TUROB, 2023).


55% of hoteliers say they feel pressured to accept the terms of the big OTAs (HotelFriend). On top of that, 51% of hotels say OTAs sell their rooms cheaper than the hotel's own website.


In 2024, Booking Holdings was named a "gatekeeper" under the EU Digital Markets Act (PhocusWire, 2026a). This shows the dependency problem is officially recognised, not just a complaint from hotels.

51.3% of hotel stays in Europe were booked directly in 2025 (HOTREC, 2026, cited in Tageskarte, 2026). Hotels haven't given up on selling directly.

Booking.com usually charges between 10% and 25% per booking, with a global average of around 15% (Guesty; SiteMinder). Expedia charges independent hotels 15–30%, while big chains pay 10–15% (Preno). Between 2019 and 2021, commission went up for 26% of hotels (i TUROB, 2023).

When the platform handles the payment, a processing fee can be added on top. Hotels are also charged commission on non-refundable bookings even when the guest cancels or doesn't show up (Guesty).

 The market is so concentrated that hotels have little bargaining power: they either accept the commission or lose visibility.
 Hotels pay commission even on no-shows, and the rules are set by a third party, not agreed between hotel and guest.

---

## 2. My Proposed Solution

### How it works

My smart contract connects two parties directly: the guest (sender), who pays, and the hotel (receiver), who gets paid. The blockchain is the middle layer that holds the money and applies the rules.

    Guest (sender) ──pays──▶ Smart Contract (escrow) ──releases at check-in──▶ Hotel (receiver)
                                    │
                                    └── refunds the guest automatically if they cancel in time

1. The hotel lists a room with its price and cancellation deadline.
2. The guest books and pays. The money is locked in the contract.
3. If the guest cancels before the deadline, the refund is automatic.
4. At check-in, the hotel confirms the guest has arrived and the contract releases the payment.
5. If the guest doesn't show up, the no-show rule agreed at booking applies.

Every step is recorded as an event on the blockchain.

### The business model

- **The hotel** pays no commission, only small network fees.
- **The guest** pays the room price and gets clear rules and automatic refunds.
- **Nobody in the middle** takes a cut. The contract's code does the job the OTA used to do.
- **Finding the hotel:** guests still need to discover it. Many hotels already use metasearch: 58% of European hotels are directly connected to one, and 83% of those use Google Hotel Ads (Tageskarte, 2026). A metasearch listing can send guests straight to the hotel's own booking page, where the contract runs.

### What changes

| | Today (OTA) | With my smart contract |
|---|---|---|
| Who holds the money | The platform | The contract (escrow), not a company |
| Who sets the rules | The platform's terms | Public code, agreed before booking |
| Cost to the hotel | Around 15% commission | A few cents in network fees |
| Refunds | Depend on customer service | Automatic and instant |
| Record of what happened | The platform's private database | A public, permanent record |
| Who you trust | The platform | The code (and the hotel at check-in) |

- The disruption isn't that hotels or guests change. It's that the middleman is replaced by code.
---

## 3. Recent Blockchain Advancements

### Bookings as NFTs

Hotel bookings have no second-hand market. If you can't travel on a non-refundable rate, you simply lose the money.

Startups are changing this by turning bookings into NFTs that can be resold. Takyon sells a "Resellable Rate" on hotels' own websites (SMAU), and Buk lets hotels earn a percentage every time a booking is resold (Future Hospitality Summit, 2023).


No hotel wants to be paid in a currency that can drop 10% overnight. Stablecoins fix this by keeping their value tied to a currency like the euro.

Since December 2024, the EU's MiCA regulation fully applies, so stablecoins in Europe are now regulated (Norton Rose Fulbright). Circle's USDC and EURC became compliant after it got an e-money licence in France in July 2024 (BlindPay).

On Ethereum's main network, one transaction can cost more than it's worth for a small payment.

Ethereum's Dencun upgrade in March 2024 made Layer 2 networks much cheaper. In the first 48 hours, fees fell 87% on Arbitrum and 88% on Base (Haig, 2024), with some networks dropping up to 98% (DL News, 2024).

Check-in still depends on physical documents, and hotels often keep more personal data than they need.

By the end of 2026, every EU country must offer a Digital Identity Wallet, and hotel check-ins have already been tested with it in Benidorm (EU Perspectives, 2026). Still, only 15–18% of travellers in the UK, France and Germany know about it (PhocusWire, 2026b).

- Each advancement removes one barrier to my idea: NFTs add flexibility, stablecoins remove volatility, Layer 2 makes fees small and digital identity helps with the real-world check-in.
- A few years ago, my contract would have been too expensive and too risky for a hotel. Since 2023, that has changed.

---

## 4. Benefits and Challenges

### Benefits

**Lower costs for hotels.**
The 15% commission becomes a few cents in network fees on a Layer 2. The money that went to the middleman stays with the hotel.

**Rules everyone can see.**
The cancellation policy is written in the contract's code, not hidden in a platform's terms. Both sides know exactly what happens before they agree, and nobody can change the rules afterwards.

**Money held safely in the middle.**
The hotel knows the money is there, and the guest knows the hotel only gets it at check-in. If the guest cancels in time, the refund is automatic, with no waiting and no customer service.

**A permanent record.**
Every step is recorded on the blockchain. If there's a disagreement, both sides can check the same history.

### Challenges

**The check-in problem.**
A smart contract can't see a guest walk into the hotel. Someone has to tell it that check-in happened, and in my design that is the hotel. So the guest still has to trust the hotel at this one step. The contract reduces trust; it doesn't remove it completely.

**Privacy and GDPR.**
Blockchain data can't be deleted, but GDPR gives people the right to have their data erased. The European Data Protection Board says personal data should not be stored on a blockchain when it conflicts with data protection principles (EDPB, 2025). Even hashed data still counts as personal data (activeMind.legal). So my contract stores no names or passport details, only wallet addresses and booking information.

**Lose your key, lose your money.**
There is no "forgot password" on a blockchain. If a guest loses their private key, or it gets stolen, nobody can recover the funds. In 2025, more than $3.4 billion was stolen in crypto hacks, and attacks on personal wallets are growing (The Block, 2025).

**Mistakes in code are hard to fix.**
Once a contract is deployed, its code can't simply be changed. A bug in the refund logic could lock guests' money, which is why testing my contract properly matters so much.


- The benefits are strongest in the middle of the process: payment, refunds and clear rules.
- The weaknesses appear at the edges, where the blockchain meets the real world: check-in, identity and key management.
- Some challenges shaped my design directly: no personal data on-chain, refund rules fixed at booking time, and only the hotel can confirm check-in.

---

## 5. Cryptography

### The method: ECDSA (secp256k1) with Keccak-256

Every Ethereum account is a pair of keys. The private key signs transactions, and the public key is created from it using the Elliptic Curve Digital Signature Algorithm (ECDSA) on the secp256k1 curve. The account's address is the last 20 bytes of the Keccak-256 hash of the public key (Ethereum.org, 2026). You can get the public key from the private key, but never the other way round.

### How it protects my contract

**Authentication: knowing who is acting.**
When the guest books, their wallet signs the transaction with their private key. The network checks the signature and identifies the sender's address, the contract saves this address in the booking.

**Access control: only the right person can act.**
Only the guest's address can cancel their booking, and only the hotel's address can list rooms and confirm check-in. Anyone else trying gets rejected by the contract.

**Non-repudiation: nobody can deny what they did.**
Only the holder of the private key can produce a valid signature. The guest can't claim "I never booked", and the hotel can't deny confirming a check-in.

**Integrity: nothing can be secretly changed.**
Keccak-256 creates a unique fingerprint (hash) of every transaction and block, and each block includes the hash of the one before it. Changing a single booking would change its hash and break the chain, so tampering is easy to spot. Each account also has a transaction counter (nonce), so a signed transaction can't be replayed to charge someone twice (Ethereum.org, 2026).

This is the best fit because:

- **It's native.** Ethereum is built on it, so my contract gets secure identities without any extra system.
- **It's efficient.** A 256-bit elliptic curve key gives about the same security as a 3,072-bit RSA key (Barker, 2020). Smaller keys and signatures mean less data and lower fees.
- **The alternatives fall short.** RSA would need much bigger keys. Symmetric encryption (like AES) uses a shared key, so it can't prove which party acted, and non-repudiation is exactly what a booking dispute needs.

What it doesn't do:

- **No confidentiality.** ECDSA signs data; it doesn't hide it. Everything on a public blockchain is visible, which is another reason my contract stores no personal data (Section 4).
- **It depends on the key.** The protection is only as strong as the guest's ability to keep their private key safe.
- **The quantum question.** Future quantum computers could break ECDSA. NIST published its first post-quantum standards in 2024 (NIST, 2024), so blockchains will eventually need to migrate.

---

## References

activeMind.legal (n.d.) *EDPB on data protection in blockchain.* Available at: https://www.activemind.legal/guides/edpb-blockchain/ (Accessed: 13 October 2026).

Aysan, A.F., Tunali, A.S. and Gozgor, G. (2023) 'Non-fungible token potentials for hotel bookings', *Annals of Tourism Research Empirical Insights*, 4(1), 100087.

Barker, E. (2020) *Recommendation for key management: Part 1 – General.* NIST Special Publication 800-57 Part 1, Revision 5. Gaithersburg, MD: National Institute of Standards and Technology. Available at: https://doi.org/10.6028/NIST.SP.800-57pt1r5 (Accessed: 13 October 2026).

BlindPay (n.d.) *MiCA stablecoin rules explained for payment companies.* Available at: https://blindpay.com/resources/more/mica-stablecoin-rules-explained (Accessed: 12 October 2026).

DL News (2024) *Ethereum's Dencun upgrade lowers layer 2 fees by as much as 98%.* Available at: https://www.dlnews.com/articles/defi/ethereums-dencun-upgrade-cuts-layer-2-fees-as-much-as-98/ (Accessed: 12 October 2026).

EDPB (2025) *EDPB adopts guidelines on processing personal data through blockchains.* Available at: https://www.edpb.europa.eu/news/edpb-adopts-guidelines-on-processing-personal-data-through-blockchains-and-is-ready-to_it (Accessed: 13 October 2026).

Ethereum.org (2026) *Ethereum accounts.* Available at: https://ethereum.org/developers/docs/accounts/ (Accessed: 13 October 2026).

EU Perspectives (2026) *EU Digital Identity Wallet faces 2026 deadline.* Available at: https://euperspectives.eu/2026/01/eu-digital-identity-wallet-fces-2026-deadline/ (Accessed: 12 October 2026).

Future Hospitality Summit (2023) *Buk Technology Inc. unveils Buktrips.com.* Available at: https://futurehospitality.com/content-library/buk-technology-inc-unveils-buktrips-com (Accessed: 12 October 2026).

Guesty (n.d.) *How much does Booking.com charge hosts?* Available at: https://www.guesty.com/blog/how-much-does-booking-com-charge-hosts (Accessed: 12 October 2026).

Haig, S. (2024) *Transaction fees on Layer 2 plummet post Dencun.* The Defiant. Available at: https://www.thedefiant.io/transaction-fees-on-layer-2-plummet-post-dencun (Accessed: 12 October 2026).

HotelFriend (n.d.) *5 surprising insights on OTAs and direct booking revealed in a HOTREC 2022 study.* Available at: https://hotelfriend.com/blogpost/insights-on-otas-and-direct-booking-revealed (Accessed: 12 October 2026).

NIST (2024) *NIST releases first 3 finalized post-quantum encryption standards.* Available at: https://www.nist.gov/news-events/news/2024/08/nist-releases-first-3-finalized-post-quantum-encryption-standards (Accessed: 13 October 2026).

Norton Rose Fulbright (n.d.) *Regulating crypto-assets in Europe: practical guide to MiCA.* Available at: https://www.nortonrosefulbright.com/en/knowledge/publications/2cec201e/regulating-crypto-assets-in-europe-practical-guide-to-mica (Accessed: 12 October 2026).

PhocusWire (2026a) *Hotel direct and OTA distribution in Europe: HOTREC study.* Available at: https://www.phocuswire.com/news/distribution/hotel-direct-ota-distribution-europe-hotrec (Accessed: 12 October 2026).

PhocusWire (2026b) *Phocuswright Europe 2026 executive panel: digital ID.* Available at: https://www.phocuswire.com/news/technology/phocuswright-europe-2026-executive-panel-digital-id (Accessed: 12 October 2026).

Preno (n.d.) *How much commission does Airbnb, Expedia and Booking.com take (+ others).* Available at: https://prenohq.com/blog/ota-commission-rates-expedia-booking-com-more/ (Accessed: 12 October 2026).

SiteMinder (n.d.) *Booking.com fees: complete guide for hosts.* Available at: https://www.siteminder.com/r/booking-com-fees/ (Accessed: 12 October 2026).

SMAU (n.d.) *Takyon.* Available at: https://www.smau.it/san-francisco/exhibitors/takyon (Accessed: 12 October 2026).

Tageskarte (2026) *Europäische Beherbergungsbetriebe verzeichnen hohe OTA-Marktkonzentration.* Available at: https://www.tageskarte.io/hotellerie/detail/europaeische-beherbergungsbetriebe-verzeichnen-hohe-ota-marktkonzentration.html (Accessed: 12 October 2026).

The Block (2025) *Crypto hacks hit $3.4 billion in 2025, attacks on individual wallets rise: Chainalysis.* Available at: https://www.theblock.co/post/382477 (Accessed: 13 October 2026).

TUROB (2023) *HOTREC online distribution channels analysis 2022.* Available at: https://turob.com/en_US/information-center/statistics/2023/show/1233/hotrec-online-distribution-channels-analysis-2022 (Accessed: 12 October 2026).
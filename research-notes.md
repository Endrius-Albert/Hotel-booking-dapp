# Research Notes – Hotel Booking DApp

## The Current Booking System

### How a booking works today

    Guest ──books & pays──▶ OTA (Booking.com / Expedia) ──pays out, minus commission──▶ Hotel

Most guests book through an Online Travel Agency (OTA). Depending on the payment model, the guest pays at the hotel, or the OTA charges the guest and pays the hotel later. Either way, the OTA sits in the middle: it controls how the hotel is shown, sets the payment rules and handles disputes.

With a smart contract, the flow becomes:

    Guest ──pays──▶ Smart Contract (escrow) ──releases at check-in──▶ Hotel

### Who controls the market

**Two companies dominate.**
Booking Holdings and Expedia Group control more than 85% of OTA hotel bookings in Europe, and almost 69% of those go through Booking Holdings alone (HOTREC, 2026, cited in PhocusWire, 2026). OTAs now account for 29.9% of all hotel bookings, up from 19.7% in 2013 (HOTREC, 2022, cited in TUROB, 2023).

**Hotels feel the pressure.**
55% of hoteliers say they feel pressured to accept the terms of the big OTAs (HotelFriend, n.d.). On top of that, 51% of hotels say OTAs sell their rooms cheaper than the hotel's own website, eight points more than in 2023 (HOTREC, 2026, cited in PhocusWire, 2026).

**Regulators have noticed.**
In 2024, Booking Holdings was named a "gatekeeper" under the EU Digital Markets Act (PhocusWire, 2026). This shows the dependency problem is officially recognised, not just a complaint from hotels.

**But direct booking is still alive.**
51.3% of hotel stays in Europe were booked directly in 2025 (HOTREC, 2026, cited in Tageskarte, 2026). Hotels haven't given up on selling directly.

### What it costs hotels

**Commission.**
Booking.com usually charges between 10% and 25% per booking, with a global average of around 15% (Guesty, n.d.; SiteMinder, n.d.). Expedia charges independent hotels 15–30%, while big chains pay 10–15% (Preno, n.d.). Between 2019 and 2021, commission went up for 26% of hotels (HOTREC, 2022, cited in TUROB, 2023).

**Costs beyond the commission.**
When the platform handles the payment, a processing fee can be added on top. Hotels are also charged commission on non-refundable bookings even when the guest cancels or doesn't show up (Guesty, n.d.).

**A note on these sources.**
Guesty, SiteMinder and Preno sell direct-booking software, so they have a commercial interest in making OTAs look expensive. Their figures are consistent with each other, but I treat them with some caution.

### My thoughts

- The market is so concentrated that hotels have little bargaining power: they either accept the commission or lose visibility.
- The money and the rules sit with a third party. In my contract, the rules are public in the code and the money stays in escrow until check-in.
- Hotels pay commission even on no-shows. A smart contract can make the no-show rule clear to both sides before the booking.

### The honest challenge

Half of all bookings are already direct, yet hotels still depend on OTAs. The reason is visibility: guests find hotels through these platforms. A smart contract removes the commission and the middleman in the payment, but it doesn't solve how guests discover the hotel in the first place.

---

## References

Guesty (n.d.) *How much does Booking.com charge hosts?* Available at: https://www.guesty.com/blog/how-much-does-booking-com-charge-hosts (Accessed: 12 October 2026).

HotelFriend (n.d.) *5 surprising insights on OTAs and direct booking revealed in a HOTREC 2022 study.* Available at: https://hotelfriend.com/blogpost/insights-on-otas-and-direct-booking-revealed (Accessed: 12 October 2026).

PhocusWire (2026) *Hotel direct and OTA distribution in Europe: HOTREC study.* Available at: https://www.phocuswire.com/news/distribution/hotel-direct-ota-distribution-europe-hotrec (Accessed: 12 October 2026).

Preno (n.d.) *How much commission does Airbnb, Expedia and Booking.com take (+ others).* Available at: https://prenohq.com/blog/ota-commission-rates-expedia-booking-com-more/ (Accessed: 12 October 2026).

SiteMinder (n.d.) *Booking.com fees: complete guide for hosts.* Available at: https://www.siteminder.com/r/booking-com-fees/ (Accessed: 12 October 2026).

Tageskarte (2026) *Europäische Beherbergungsbetriebe verzeichnen hohe OTA-Marktkonzentration.* Available at: https://www.tageskarte.io/hotellerie/detail/europaeische-beherbergungsbetriebe-verzeichnen-hohe-ota-marktkonzentration.html (Accessed: 12 October 2026).

TUROB (2023) *HOTREC online distribution channels analysis 2022.* Available at: https://turob.com/en_US/information-center/statistics/2023/show/1233/hotrec-online-distribution-channels-analysis-2022 (Accessed: 12 October 2026).
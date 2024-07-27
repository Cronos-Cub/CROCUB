# Developer Vesting Schedule for CronosCub ($CROCUB)

The vesting schedule for developers in the CronosCub project is designed to ensure long-term commitment and alignment with the project's goals. This document outlines the specific details of the vesting arrangement.

## Overview

The developer reserve comprises 10% of the total supply of CronosCub tokens, amounting to 300,000 $CROCUB out of a total supply of 3,000,000 $CROCUB.

## Vesting Details

### Initial Release

- **Amount**: 60,000 $CROCUB
- **Percentage**: 20% of the total developer reserve
- **Timing**: Released immediately upon contract deployment

### Vesting Period

- **Duration**: 24 months (2 years)
- **Amount**: 240,000 $CROCUB
- **Percentage**: 80% of the total developer reserve
- **Type**: Linear vesting over the period

### Vesting Mechanics

1. **Total Developer Reserve**: 300,000 $CROCUB
2. **Initial Release**: 20% (60,000 $CROCUB) upon deployment
3. **Remaining Amount**: 240,000 $CROCUB vesting over 24 months

#### Linear Vesting Calculation

- The remaining 240,000 $CROCUB tokens are released linearly over the 24-month period. The number of tokens that can be released at any point in time is calculated based on the elapsed time since the contract's deployment.

#### Function for Releasing Vested Tokens

The smart contract includes a `releaseDevTokens` function to manage the release of vested tokens. The function uses the following logic:

- **Elapsed Time Calculation**: `elapsedTime = block.timestamp - startTime`
- **Total Releasable Tokens**: `totalReleasable = (DEV_RESERVE * elapsedTime) / VESTING_DURATION`
- **Releasable Amount**: `releasableAmount = totalReleasable - devReleased`

The function then updates the state and transfers the tokens to the developer address.

## Security and Transparency

The vesting schedule is implemented to ensure:

- **Commitment**: Developers are incentivized to contribute to the project's success over the long term.
- **Market Stability**: Gradual release prevents large token dumps that could destabilize the market.
- **Transparency**: Clear, predictable release schedules provide transparency to the community and stakeholders.

## Conclusion

The developer vesting schedule for CronosCub is a crucial component of the project's governance and operational framework. It aligns the interests of the developers with the long-term success of the project, ensuring sustainable growth and stability in the ecosystem.

For any inquiries or further details, please contact the CronosCub team.

---

**CronosCub Team**

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./TrancheConstant.sol";

contract TrancheProportionModel {
  function maxDepositableValue(
    uint256 _trancheIndex,
    uint256[] memory _trancheTvls,
    uint256 _maxAssetValue
  ) external pure returns (uint256) {
    uint256 seniorTvl = _trancheTvls[TrancheConstant.SENIOR_TRANCHE_INDEX];
    uint256 mezzanineTvl = _trancheTvls[
      TrancheConstant.MEZZANINE_TRANCHE_INDEX
    ];
    uint256 juniorTvl = _trancheTvls[TrancheConstant.JUNIOR_TRANCHE_INDEX];

    uint256 capLeft = _subFloor0(
      _maxAssetValue,
      (seniorTvl + mezzanineTvl + juniorTvl)
    );

    if (_trancheIndex == TrancheConstant.JUNIOR_TRANCHE_INDEX) {
      return capLeft;
    }

    if (_trancheIndex == TrancheConstant.MEZZANINE_TRANCHE_INDEX) {
      return _min(_subFloor0(juniorTvl * 2, mezzanineTvl), capLeft);
    }

    if (_trancheIndex == TrancheConstant.SENIOR_TRANCHE_INDEX) {
      return _min(_subFloor0(juniorTvl + mezzanineTvl, seniorTvl), capLeft);
    }

    return 0;
  }

  function maxWithdrawableValue(
    uint256 _trancheIndex,
    uint256[] memory _trancheTvls
  ) external pure returns (uint256) {
    uint256 seniorTvl = _trancheTvls[TrancheConstant.SENIOR_TRANCHE_INDEX];
    uint256 mezzanineTvl = _trancheTvls[
      TrancheConstant.MEZZANINE_TRANCHE_INDEX
    ];
    uint256 juniorTvl = _trancheTvls[TrancheConstant.JUNIOR_TRANCHE_INDEX];

    if (_trancheIndex == TrancheConstant.JUNIOR_TRANCHE_INDEX) {
      return
        _min(
          _subFloor0(juniorTvl, (mezzanineTvl / 2)),
          _subFloor0(juniorTvl + mezzanineTvl, seniorTvl)
        );
    }

    if (_trancheIndex == TrancheConstant.MEZZANINE_TRANCHE_INDEX) {
      return
        _min(_subFloor0(juniorTvl + mezzanineTvl, seniorTvl), mezzanineTvl);
    }

    if (_trancheIndex == TrancheConstant.SENIOR_TRANCHE_INDEX) {
      return seniorTvl;
    }

    return 0;
  }

  function _subFloor0(uint256 _x, uint256 _y) internal pure returns (uint256) {
    return _x >= _y ? _x - _y : 0;
  }

  function _min(uint256 _x, uint256 _y) internal pure returns (uint256) {
    return _x < _y ? _x : _y;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

library TrancheConstant {
  /// @dev enum
  uint8 public constant SETUP_PHASE = 0;
  uint8 public constant PREPARATION_PHASE = 1;
  uint8 public constant INVESTMENT_PHASE = 2;
  uint8 public constant SETTLEMENT_PHASE = 3;
  uint8 public constant DEAD_PHASE = 4;

  uint8 public constant SENIOR_TRANCHE_INDEX = 0;
  uint8 public constant MEZZANINE_TRANCHE_INDEX = 1;
  uint8 public constant JUNIOR_TRANCHE_INDEX = 2;

  address public constant USD_ADDRESS =
    0x115dffFFfffffffffFFFffffFFffFfFfFFFFfFff;
}
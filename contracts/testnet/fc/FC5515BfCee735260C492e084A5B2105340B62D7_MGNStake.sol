// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IMGNLAND {
    function _lockLand(uint256 tokenId, address sender) external;

    function _unlockLand(uint256 tokenId, address sender) external;
}

interface IMGNToken {
    function mint(address to, uint256 amount) external;
}

contract MGNStake {
    struct stLand {
        uint256 tokenId;
        address wallet;
        uint256 stakeID;
        uint256 Month;
        uint256 Roi;
        uint256 timestamp;
        bool isLocked;
        uint256 expiration;
        uint256 benefits;
    }

    stLand[] stakes;

    event staked(
        uint8 stakeId,
        address owner,
        uint256 amount,
        uint256 _month,
        uint256 _roi
    );

    uint8[3] month = [6, 9, 12];
    uint256 extra = 0.0003 ether;
    uint256 pricePerLand = 100;
    address landAddress;
    address mgnAddress;
    mapping(uint256 => uint256) roi;

    uint8 StakeID = 0;
    IMGNToken mgntoken;
    IMGNLAND land;
    uint256 stakeAmount = 0;

    constructor(address _landAddress, address _mgnAddress) {
        land = IMGNLAND(_landAddress);
        mgntoken = IMGNToken(_mgnAddress);
        uint64[3] memory _roi = [0.05 ether, 0.12 ether, 0.22 ether];
        for (uint256 i = 0; i < month.length; i++) {
            roi[month[i]] = _roi[i];
        }
    }

    function stakeLand(uint256[] memory _tokenId, uint256 _month) public {
        require(
            _month == month[0] || _month == month[1] || _month == month[2],
            "Must provide month matching to the required data"
        );
        uint8 stakeId = StakeID++;
        uint256 amount = _tokenId.length;
        for (uint256 i = 0; i < _tokenId.length; i++) {
            land._lockLand(_tokenId[i], msg.sender); // lock lands
            stakes.push(
                stLand({
                    tokenId: _tokenId[i],
                    wallet: payable(msg.sender),
                    stakeID: stakeId,
                    Roi: roi[_month],
                    Month: _month,
                    timestamp: block.timestamp,
                    isLocked: true,
                    expiration: block.timestamp + _month * 1 seconds,
                    benefits: getBenefits(amount, roi[_month])
                })
            );
        }
        emit staked(stakeId, msg.sender, amount, _month, roi[_month]);
    }

    function getBenefits(uint256 _amount, uint256 _roi)
        public
        view
        returns (uint256)
    {
        uint256 _benefits;
        uint256 _totalPrice = _amount * pricePerLand;
        _benefits = (_totalPrice * _roi);

        if (_amount >= 2) {
            _benefits = _benefits + (_totalPrice * extra);
        } else if (_amount > 100) {
            _benefits = _benefits + (100 * pricePerLand * extra);
        }
        return _benefits;
    }

    function unstakeLand(uint256 _stakeId) public {
        uint256 _benefits;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (_stakeId == stakes[i].stakeID) {
                require(stakes[i].isLocked == true, "The land must be locked");
                require(
                    stakes[i].wallet == msg.sender,
                    "The land must be owned by sender"
                );
                require(
                    block.timestamp >= stakes[i].expiration,
                    "The land haven't reached the due"
                );

                land._unlockLand(stakes[i].tokenId, msg.sender); // unlock lands
                _benefits = stakes[i].benefits;
                delete stakes[i];
            } else if (_stakeId != stakes[i].stakeID) {
                revert();
            }
        }
        mgntoken.mint(msg.sender, _benefits);
    }

    function getStakes() public view returns (stLand[] memory) {
        return stakes;
    }

    function getStakeByOwner(address _address)
        public
        view
        returns (stLand[] memory)
    {
        uint256 _amount = getAmountbyOwner(_address);
        stLand[] memory _owned = new stLand[](_amount);

        uint256 index = 0;
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].wallet == _address) {
                _owned[index] = stakes[i];
                index++;
            }
        }
        return _owned;
    }

    function getAmountbyOwner(address _address)
        internal
        view
        returns (uint256)
    {
        uint256 _amount = stakeAmount;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].wallet == _address) {
                _amount++;
            }
        }
        return _amount;
    }

    function getStakeByStakeId(uint256 _stakeId)
        public
        view
        returns (stLand[] memory)
    {
        uint256 _amount = getAmountbyStakeId(_stakeId);
        stLand[] memory _staked = new stLand[](_amount);

        uint256 index = 0;
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].stakeID == _stakeId) {
                _staked[index] = stakes[i];
                index++;
            }
        }
        return _staked;
    }

    function getAmountbyStakeId(uint256 _satkeId)
        internal
        view
        returns (uint256)
    {
        uint256 _amount = stakeAmount;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].stakeID == _satkeId) {
                _amount++;
            }
        }
        return _amount;
    }
}
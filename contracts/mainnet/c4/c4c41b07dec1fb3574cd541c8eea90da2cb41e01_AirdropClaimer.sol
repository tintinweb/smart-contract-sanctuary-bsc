// SPDX-License-Identifier: WISE

//@author RenevonMangoldt.eth
//@helper vitally.eth

import "./AirdropClaimerToken.sol";
import "./Interfaces.sol";

pragma solidity ^0.8.17;

error ImpossibleMint();
error ImpossibleClaim();

contract AirdropClaimer is AirdropClaimerToken {

    IToken public immutable BUSD;
    IAirdropRegister public immutable airdropRegister;

    uint256 public totalBusdClaimed;
    uint256 public totalBusdContributed;

    mapping(address => uint256) public sharesClaimed;

    modifier cleanUp() {
        _cleanUp();
        _;
    }

    constructor(
        IToken _busdTokenAddress,
        IAirdropRegister _airdropRegister,
        address[] memory _preSettledAddresses,
        address[] memory _publicContributors,
        uint256[] memory _preSettledAmounts,
        uint256[] memory _publicContributorAmounts,
        string memory _entryName,
        string memory _entrySymbol,
        uint8 _decimalsInput
    )
    {
        _name = _entryName;
        _symbol = _entrySymbol;
        _decimals = _decimalsInput;

        BUSD = _busdTokenAddress;
        airdropRegister = _airdropRegister;

        for (uint256 i = 0; i < _preSettledAddresses.length; i++) {
            sharesClaimed[_preSettledAddresses[i]] = _preSettledAmounts[i];
        }

        for (uint256 i = 0; i < _publicContributors.length; i++) {
            _mint(
                _publicContributors[i],
                _publicContributorAmounts[i]
            );
        }
    }

    function contribute(
        uint256 _amount
    )
        cleanUp
        external
    {
        totalBusdContributed += _amount;

        BUSD.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }

    function mintShares(
        address _user
    )
        cleanUp
        external
    {
        uint256 shareAmount = sharesClaimable(
            _user
        );

        if (shareAmount == 0) {
            revert ImpossibleMint();
        }

        sharesClaimed[_user] += shareAmount;

        _mint(
            _user,
            shareAmount
        );
    }

    function burnShares()
        cleanUp
        external
    {
        (
            uint256 claimAmount,
            uint256 userBalance
        ) = airdropValueForUser(
            msg.sender
        );

        totalBusdClaimed += claimAmount;

        _burn(
            msg.sender,
            userBalance
        );

        BUSD.transfer(
            msg.sender,
            claimAmount
        );
    }

    function _cleanUp()
        internal
    {
        uint256 cleanUpAmount = _cleanUpAmount(
            totalBusdClaimed,
            totalBusdContributed,
            totalClaimable()
        );

        if (cleanUpAmount == 0) return;

        totalBusdContributed += cleanUpAmount;
    }

    function _cleanUpAmount(
        uint256 _totalBusdClaimed,
        uint256 _totalBusdContributed,
        uint256 _balanceContract
    )
        internal
        pure
        returns (uint256)
    {
        return _balanceContract
            + _totalBusdClaimed
            - _totalBusdContributed;
    }

    function totalClaimable()
        public
        view
        returns (uint256)
    {
        return BUSD.balanceOf(
            address(this)
        );
    }

    function sharesClaimable(
        address _user
    )
        public
        view
        returns (uint256)
    {
        return airdropRegister.userShares(_user)
            - sharesClaimed[_user];
    }

    function airdropValueForUser(
        address _user
    )
        public
        view
        returns (
            uint256,
            uint256
        )
    {
        uint256 userBalance = _balances[
            _user
        ];

        uint256 claimAmount = totalClaimable()
            * userBalance
            / _totalSupply;

        if (claimAmount == 0) {
            revert ImpossibleClaim();
        }

        return (
            claimAmount,
            userBalance
        );
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface ICrssReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function getOutstandingCommission(address _referrer)
        external
        view
        returns (uint256 amount);

    function debitOutstandingCommission(address _referrer, uint256 _debit)
        external;

    function updateOperator(address _newPayer) external;
}

contract CrssReferral is ICrssReferral, Context {
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public countReferrals; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions
    mapping(address => uint256) public outstandingCommissions;

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(
        address indexed referrer,
        uint256 commission
    );
    event OperatorUpdated(address indexed operator, bool indexed status);
    struct ReferralObject {
        address referrer;
        address user;
    }
    address public payer;
    //added control center for updating payer address function, which wasnt present before, removes the need for Ownable contract
    address public controlCenter;

    constructor(address _controlCenter) {
        controlCenter = _controlCenter;
    }

    //this is the function that will be called from offchain, takes an object array {address,address} as parameter
    function bulkRecordReferralFromOffchain(
        ReferralObject[] memory _objectArray
    ) public {
        //require(_msgSender() == payer, "Only payer can record referrers");
        for (uint256 i = 0; i < _objectArray.length; i++) {
            recordReferral(_objectArray[i].user, _objectArray[i].referrer);
        }
    }

    function recordReferral(address _user, address _referrer) public override {
        // require(_msgSender() == payer, "Only payer can record referrers");
        if (referrers[_user] == address(0)) {
            referrers[_user] = _referrer;
            countReferrals[_referrer] += 1;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission)
        public
        override
    {
        //require(_msgSender() == payer, "Only payer can record commission");
        totalReferralCommissions[_referrer] += _commission;
        outstandingCommissions[_referrer] += _commission;
        emit ReferralCommissionRecorded(_referrer, _commission);
    }

    function getOutstandingCommission(address _referrer)
        external
        view
        override
        returns (uint256 amount)
    {
        amount = outstandingCommissions[_referrer];
    }

    //this function was exclusive to payer, but I removed the requirement so the person who is owed the comission can also claim it for themselves
    //payment not yet implemented
    function debitOutstandingCommission(address _referrer, uint256 _debit)
        external
        override
    {
        require(
            _msgSender() == _referrer || _msgSender() == payer,
            "Only payer can debit outstanding commission"
        );
        outstandingCommissions[_referrer] -= _debit;
    }

    // Get the referrer address that referred the user
    function getReferrer(address _user) public view override returns (address) {
        return referrers[_user];
    }

    //this is the wallet that will be used to sign the transaction needed to execute the recordReferral() functions
    function updateOperator(address _newPayer) external {
        require(msg.sender == controlCenter, "Only Control center");
        payer = _newPayer;
    }
}
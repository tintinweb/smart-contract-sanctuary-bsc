// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "./Policy.sol";

contract FactoryStorage is Policy {
    /* ======== STRUCTS ======== */

    struct BillDetails {
        address _payoutToken;
        address _principalToken;
        address _treasuryAddress;
        address _billAddress;
        address _billNft;
        uint256[] _tierCeilings;
        uint256[] _fees;
    }

    /* ======== STATE VARIABLES ======== */
    BillDetails[] public billDetails;

    address public billFactory;

    mapping(address => uint256) public indexOfBill;

    /* ======== EVENTS ======== */

    event BillCreation(address treasury, address bill, address nftAddress);
    event FactoryChanged(address newFactory);

    /* ======== POLICY FUNCTIONS ======== */

    /**
        @notice pushes bill details to array
        @param _payoutToken address
        @param _principalToken address
        @param _customTreasury address
        @param _customBill address
        @param _nftAddress address
        @param _tierCeilings uint[]
        @param _fees uint[]
        @return _treasury address
        @return _bill address
     */
    function pushBill(
        address _payoutToken,
        address _principalToken,
        address _customTreasury,
        address _customBill,
        address _nftAddress,
        uint256[] calldata _tierCeilings,
        uint256[] calldata _fees
    ) external returns (address _treasury, address _bill) {
        require(billFactory == msg.sender, "Not Factory");

        indexOfBill[_customBill] = billDetails.length;

        billDetails.push(
            BillDetails({
                _payoutToken: _payoutToken,
                _principalToken: _principalToken,
                _treasuryAddress: _customTreasury,
                _billAddress: _customBill,
                _billNft: _nftAddress,
                _tierCeilings: _tierCeilings,
                _fees: _fees
            })
        );

        emit BillCreation(_customTreasury, _customBill, _nftAddress);
        return (_customTreasury, _customBill);
    }

    /**
        @notice returns total bills
     */
    function totalBills() external view returns(uint) {
        return  billDetails.length;
    }

    function billFees(uint256 _billId) external view returns (uint256[] memory, uint256[] memory) {
        BillDetails memory bill = billDetails[_billId];
        uint256 length = bill._tierCeilings.length;
        uint256[] memory _tierCielings = new uint[](length);
        uint256[] memory _fees = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            _tierCielings[i] = bill._tierCeilings[i];
            _fees[i] = bill._fees[i];
        }
        return (_tierCielings, _fees);
    }

    /**
        @notice changes factory address
        @param _factory address
     */
    function setFactoryAddress(address _factory) external onlyPolicy {
        billFactory = _factory;
        emit FactoryChanged(billFactory);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newPolicy_) external;

    function pullPolicy() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

import "./interfaces/IPolicy.sol";

contract Policy is IPolicy {
    address internal _policy;
    address internal _newPolicy;

    event PolicyTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event PolicyPushed(
        address indexed newPolicy
    );

    constructor() {
        _policy = msg.sender;
        emit PolicyTransferred(address(0), _policy);
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    function newPolicy() public view returns (address) {
        return _newPolicy;
    }

    modifier onlyPolicy() {
        require(_policy == msg.sender, "Caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit PolicyTransferred(_policy, address(0));
        _policy = address(0);
        _newPolicy = address(0);
    }

    function pushPolicy(address newPolicy_) public virtual override onlyPolicy {
        require(
            newPolicy_ != address(0),
            "New owner is the zero address"
        );
        emit PolicyPushed(newPolicy_);
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newPolicy, "msg.sender is not new policy");
        emit PolicyTransferred(_policy, _newPolicy);
        _policy = _newPolicy;
    }
}
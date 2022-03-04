// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Policy.sol";

contract FactoryStorage is Policy {
    /* ======== STRUCTS ======== */

    struct BillDetails {
        address _payoutToken;
        address _principleToken;
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

    /* ======== POLICY FUNCTIONS ======== */

    /**
        @notice pushes bill details to array
        @param _payoutToken address
        @param _principleToken address
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
        address _principleToken,
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
                _principleToken: _principleToken,
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

    /**
        @notice changes factory address
        @param _factory address
     */
    function setFactoryAddress(address _factory) external onlyPolicy {
        billFactory = _factory;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newPolicy_) external;

    function pullPolicy() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./interfaces/IPolicy.sol";

contract Policy is IPolicy {
    address internal _policy;
    address internal _newPolicy;

    event PolicyTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _policy = msg.sender;
        emit PolicyTransferred(address(0), _policy);
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    modifier onlyPolicy() {
        require(_policy == msg.sender, "Policy: caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit PolicyTransferred(_policy, address(0));
        _policy = address(0);
    }

    function pushPolicy(address newPolicy_) public virtual override onlyPolicy {
        require(
            newPolicy_ != address(0),
            "Policy: new owner is the zero address"
        );
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newPolicy, "Policy: msg.sender is not new policy");
        emit PolicyTransferred(_policy, _newPolicy);
        _policy = _newPolicy;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./interfaces/IERC20.sol";
import "./libraries/TransferHelper.sol";
import "./utils/Ownable.sol";

contract Crowdfunding is Ownable {
    ///////////////////////////////////
    ////// VARIABLES
    uint256 public totalFunds;
    bool isInitialzed;
    IERC20 public token;

    ///////////////////////////////////
    ////// EVENTS
    event FundCreated(
        uint256 fundIndex,
        uint256 amountToRaise,
        uint256 amountRaised,
        uint32 endtTime,
        address creator,
        bool isClaimed
    );

    event Donation(uint256 fundIndex, uint256 amount, address donorAddress);

    event FundWithdrawal(uint256 fundIndex, bool isClaimed);

    ///////////////////////////////////
    ////// STRUCTS
    struct Crowdfund {
        uint256 amountToRaise;
        uint256 amountRaised;
        uint32 endTime;
        address creator;
        bool isClaimed;
    }
    mapping(uint256 => Crowdfund) public fundInfo;

    struct Donor {
        uint256 donatedAmount;
    }
    mapping(address => mapping(uint256 => Donor)) public donorInfo;

    ///////////////////////////////////
    ////// CONSTRUCTOR/INITIALIZE

    receive() external payable {
        TransferHelper.safeTransferETH(owner, msg.value);
    }

    // constructor(IERC20 _tokenAddress) {
    //     token = _tokenAddress;
    // }

    function initialize(address _owner, IERC20 _tokenAddress) public {
        require(!isInitialzed, "Already initialzed");
        isInitialzed = true;

        _setOwner(_owner);
        token = _tokenAddress;
    }

    ///////////////////////////////////
    ////// FUND CREATION

    // Function let users create a new fund
    function createNewFund(uint256 _amountToRaise, uint32 _endTime) external {
        require(_amountToRaise > 0, "Amount to raise cannot be zero.");
        require(
            block.timestamp < _endTime + uint32(block.timestamp),
            "Current time cannot be more than end time."
        );

        // Values set
        Crowdfund memory newFund = Crowdfund({
            amountToRaise: _amountToRaise,
            amountRaised: 0,
            endTime: _endTime + uint32(block.timestamp),
            creator: msg.sender,
            isClaimed: false
        });
        fundInfo[++totalFunds] = newFund;

        // Emits an event
        emit FundCreated(
            totalFunds,
            _amountToRaise,
            0,
            newFund.endTime,
            msg.sender,
            false
        );
    }

    ///////////////////////////////////
    ////// FUND DONATION

    // Function let donors donate to a fund
    function donateToFund(uint256 _fundIndex, uint256 _amount) external {
        require(_fundIndex <= totalFunds, "Fund doesn't exist.");

        Crowdfund storage fund = fundInfo[_fundIndex];

        require(fund.endTime > block.timestamp, "Fund time is over.");

        require(
            fund.amountRaised < fund.amountToRaise,
            "Amount is already raised."
        );

        // User's balance check
        require(
            token.balanceOf(msg.sender) >= _amount,
            "User doesn't have enough balance to bet."
        );
        require(
            token.allowance(msg.sender, address(this)) >= _amount,
            "Allowance issue."
        );

        donorInfo[msg.sender][_fundIndex].donatedAmount += _amount;
        fundInfo[_fundIndex].amountRaised += _amount;

        TransferHelper.safeTransferFrom(
            address(token),
            msg.sender,
            address(this),
            _amount
        );

        emit Donation(_fundIndex, _amount, msg.sender);
    }

    ///////////////////////////////////
    ////// RAISED AMOUNT CLAIM

    // Function let user claim the raised amount
    function claimRaisedAmount(uint256 _fundIndex) external {
        Crowdfund storage fund = fundInfo[_fundIndex];

        require(
            fund.creator == msg.sender,
            "You are not the creator of the fund"
        );

        require(
            fund.amountRaised >= fund.amountToRaise,
            "Fund has not been raised."
        );

        require(!fund.isClaimed, "Already claimed");

        fund.isClaimed = true;

        TransferHelper.safeTransfer(
            address(token),
            msg.sender,
            fund.amountRaised
        );
    }

    ///////////////////////////////////
    ////// DONATION WITHDRAWAL

    // Function let users claim their donation back in case the fund fails
    function withdrawDonation(uint256 _fundIndex) external {
        require(_fundIndex <= totalFunds, "Fund doesn't exist.");

        Crowdfund storage fund = fundInfo[_fundIndex];
        Donor storage donor = donorInfo[msg.sender][_fundIndex];

        require(donor.donatedAmount > 0, "You have not donated to this fund.");
        require(fund.endTime < block.timestamp, "Fund is still active.");

        fund.amountRaised -= donor.donatedAmount;

        TransferHelper.safeTransfer(
            address(token),
            msg.sender,
            donor.donatedAmount
        );

        donor.donatedAmount = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool success);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner Access");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}
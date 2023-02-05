// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AthTraderCEX.sol";
import {AthenaReferral, SafeBEP20, Address, Context, Ownable} from "./AthReferral.sol";

contract AthTraderCEXFactory {
    // fee to be paid for creating a tradingContract
    uint256 public traderDeploymentFee = 0.1 ether;

    // array of all created tradingContracts
    address[] public traders;

    // address of owner
    address public owner;

    // address of AthStaking contract
    address athLevel;

    // address of AthReferral contract
    address athReferral;

    /**
     * @dev returns the index of the trader in the traders array, mind that actual index is index - 1 because of the 0 default value
     */
    mapping(address => uint256) public traderIndex;

    /**
     * @dev create instance of this contract
     */
    constructor(address athLevel_) {
        owner = msg.sender;
        athLevel = athLevel_;
        athReferral = address(new AthenaReferral());
    }

    // To check if accessed by an owner
    modifier onlyOwner() {
        isOwner();
        _;
    }

    /**
     * @dev returns length of traders array
     */
    function tradersLength() external view returns (uint256) {
        return traders.length;
    }

    /**
     * @dev removes Trader from traders array and from traderIndex mapping by address
     * @param tradersToRemove_ array of traders addresses to be removed
     * @notice only owner can call this function
     */
    function removeTraderByAddress(address[] memory tradersToRemove_)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < tradersToRemove_.length; i++) {
            require(
                traderIndex[tradersToRemove_[i]] != 0,
                "Trader does not exist!"
            );
            removeTraderByIndex(traderIndex[tradersToRemove_[i]] - 1);
        }
    }

    /**
     * @dev removes Trader from traders array and from traderIndex mapping by index
     * @param index_ index of trader to be removed
     * @notice only owner can call this function
     */
    function removeTraderByIndex(uint256 index_) public onlyOwner {
        if (index_ == traders.length - 1) {
            traderIndex[traders[index_]] = 0;
            traders.pop();
        } else {
            traderIndex[traders[index_]] = 0;
            traders[index_] = traders[traders.length - 1];
            traderIndex[traders[index_]] = index_ + 1;
            traders.pop();
        }
    }

    /**
     * @dev sets the fee that  trader needs to pay for deploying a tradingContract
     * @param fee_ fee that trader needs to pay for deploying a tradingContract
     * @notice only owner can call this function
     */
    function setTraderDeploymentFee(uint256 fee_) external onlyOwner {
        traderDeploymentFee = fee_;
    }

    /**
     * @dev deploy a trading contract
     * @param traderAddress address of trader
     */
    function createTrader(address traderAddress)
        external
        payable
        returns (AthTraderCEX)
    {
        // Collect fee from sender
        require(
            msg.value >= traderDeploymentFee,
            "Insufficient deployment fee."
        );
        // Send fee to owner address
        payable(owner).transfer(msg.value);
        return _deployTrader(payable(traderAddress));
    }

    /**
     * @dev deploy a trading contract without fee
     * @notice only owner can call this function
     * @param traderAddress address of trader
     */
    function createTraderByOwner(address traderAddress)
        external
        onlyOwner
        returns (AthTraderCEX)
    {
        return _deployTrader(payable(traderAddress));
    }

    /**
     * @dev returns traders array
     */
    function getTraders() external view returns (address[] memory) {
        return traders;
    }

    /**
     * @dev internal function to deploy a trading contract
     * @param traderAddress address of trader
     */
    function _deployTrader(address payable traderAddress)
        internal
        returns (AthTraderCEX)
    {
        AthTraderCEX trader = new AthTraderCEX(
            athLevel,
            athReferral,
            traderAddress
        );
        traders.push(address(trader));
        traderIndex[address(trader)] = traders.length;
        IREFERRAL(athReferral).addOperator(address(trader));
        return trader;
    }

    /**
     * @dev set owner of this contract
     * @param newOwner_ address of new owner
     * @notice only owner can call this function
     */
    function transferOwnership(address newOwner_) external onlyOwner {
        owner = newOwner_;
    }

    /**
     * * @dev view function to check msg.sender is owner
     */
    function isOwner() internal view {
        require(owner == msg.sender, "29");
    }
}
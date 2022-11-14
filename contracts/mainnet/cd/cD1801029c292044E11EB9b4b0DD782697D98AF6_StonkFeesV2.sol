// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Pancakeswap.sol";
import "./Constants.sol";
import "./IStonksVotingToken.sol";
import "./Ownable.sol";

/**
 * STONKS
 *
 * Coin: 0xC2973496E7c568D6EEcBF1d4234A24aa2FD71bd8
 *
 * App: https://app.stonks.cash
 *
 * Website: https://stonks.cash
 *
 * Telegram: https://t.me/stonksCoinBsc
 *
 * Created by: https://github.com/fryzjerr
 *
 * From Yolo Doggins with love <3
 */
contract StonkFeesV2 is Ownable {
    string public name = "StonkFeesV2";

    uint8 public fee = 5; // 0.5%
    uint8 public feeSplit = 50; // 50% to stakers 50% to team

    uint public totalFees;
    uint public undistributedFees;

    uint public totalUnclaimedFees;
    uint public totalStakedStonks;

    address[] public _unclaimedFeesAddresses;
    mapping(address => Staker) public unclaimedFees;

    address[] public stakersAddresses;
    mapping(address => Staker) public stakers;

    address teamWallet = 0xbCbA1dC6bEf1A2083331DFC0D72e0A76dF47204E;

    IStonksVotingToken votingToken;

    struct Staker {
        uint amount;
        uint arrayIndex;
        int8 exists;
    }

    constructor (address votingTokenAddress) {
        transferOwnership(tx.origin);
        totalFees = 0;
        undistributedFees = 0;
        totalUnclaimedFees = 0;
        totalStakedStonks = 0;

        stakers[teamWallet] = Staker(0, 0, 1);
        unclaimedFees[teamWallet] = Staker(0, 0, 1);

        votingToken = IStonksVotingToken(votingTokenAddress);
    }

    function changeTeamWallet(address newAddress) external onlyOwner {
        teamWallet = newAddress;
    }

    function changeTeamWalletAsTeam(address newAddress) external {
        require(msg.sender == teamWallet, "Caller must be the team address!");
        teamWallet = newAddress;
    }

    function changeFee(uint8 newFee) external onlyOwner {
        fee = newFee;
    }

    function changeFeeSplit(uint8 newFeeSplit) external onlyOwner {
        feeSplit = newFeeSplit;
    }


    function getVotingTokenAddress() external view returns(address) {
        return address(votingToken);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit(uint amount) payable external {
        require(msg.value == amount);

        totalFees += msg.value;
        undistributedFees += msg.value;
    }

    function depositFee(uint amount) payable external {
        require(msg.value == amount);

        totalFees += msg.value;
        undistributedFees += msg.value;
    }

    /**
    * Takes fee (in BNB) from the address that invoked the transaction
    */
    function takeFee(uint orderWorthBNB) public returns (uint amount) {
        amount = computeFee(orderWorthBNB);

        IBEP20(Constants.WBNB()).transferFrom(tx.origin, address(this), amount);
        totalFees = totalFees + amount;
        undistributedFees = undistributedFees + amount;
    }

    /**
    * Computes fees for given worth in BNB
    */
    function computeFee(uint orderWorthBNB) public view returns (uint) {
        return orderWorthBNB * fee / 1000;
    }

    /**
    * Computes fees for given worth in BNB
    */
    function computeFeeFromToken(uint amountIn, address tokenIn) public view returns (uint) {
        uint amountBNB = getCurrentAmountOut(amountIn, tokenIn, Constants.WBNB());
        return computeFee(amountBNB);
    }

    /**
    * Returns current amount out from pancakeRouter
    */
    function getCurrentAmountOut(uint amountIn, address tokenIn, address tokenOut) internal view returns (uint amount) {
        address[] memory tokens = new address[](2);
        tokens[0] = tokenIn;
        tokens[1] = tokenOut;

        return Constants.pancakeRouter().getAmountsOut(amountIn, tokens)[1];
    }

    /**
    * Distributes fees from undistributed fees to unclaimed fees mapping
    */
    function distributeFees() public {
        uint newStonksBalance = IBEP20(Constants.STONK()).balanceOf(address(this));
        uint newBalanceRatio = newStonksBalance / totalStakedStonks;
        uint teamFees = undistributedFees * feeSplit / 100;

        teamFees = undistributedFees - teamFees;

        undistributedFees -= teamFees;
        unclaimedFees[teamWallet].amount += teamFees;

        for (uint i = 0; i < stakersAddresses.length; i++) {
            address stakersAddress = stakersAddresses[i];

            if (unclaimedFees[stakersAddress].exists == 0) {
                _unclaimedFeesAddresses.push(stakersAddress);
                unclaimedFees[stakersAddress] = Staker(0, _unclaimedFeesAddresses.length - 1, 1);
            }

            unclaimedFees[stakersAddress].amount += undistributedFees * stakers[stakersAddress].amount / totalStakedStonks;
            stakers[stakersAddress].amount = stakers[stakersAddress].amount * newBalanceRatio;
        }

        totalUnclaimedFees += teamFees;
        totalUnclaimedFees += undistributedFees;
        undistributedFees = 0;
        totalStakedStonks = newStonksBalance;
    }

    /**
    * Claims dividend for the tx.origin
    */
    function claimDividend() external {
        claimDividendFor(tx.origin);
    }

    /*
    * Claims dividend for the receiver
    */
    function claimDividendFor(address receiver) public {
        require(unclaimedFees[receiver].amount > 0, "You have no dividend to claim!");

        uint amount = unclaimedFees[receiver].amount;

        payable(receiver).transfer(amount);

        unclaimedFees[receiver].amount = 0;

        if (stakers[receiver].exists == 0) {
            removeFromUnclaimedFeesAddresses(unclaimedFees[receiver].arrayIndex);
            unclaimedFees[receiver] = Staker(0, 0, 0);
        }
    }

    /*
    * Claims dividend for everyone
    */
    function claimDividendForAll() external {
        if (unclaimedFees[teamWallet].amount > 0) {
            claimDividendFor(teamWallet);
        }

        for (uint i = 0; i < _unclaimedFeesAddresses.length; i++) {
            address receiver = _unclaimedFeesAddresses[i];

            if (unclaimedFees[receiver].amount > 0) {
                claimDividendFor(receiver);
            }
        }
    }

    function removeFromUnclaimedFeesAddresses(uint index) internal {
        _unclaimedFeesAddresses[index] = _unclaimedFeesAddresses[_unclaimedFeesAddresses.length - 1];
        stakers[_unclaimedFeesAddresses[index]].arrayIndex = index;

        _unclaimedFeesAddresses.pop();
    }

    /**
    *   Adds coins to the stake to let the adding address claim rewards
    */
    function addStake(uint amount) external {
        require(
            IBEP20(Constants.STONK()).allowance(tx.origin, address(this)) >= amount,
            "Not enough allowance!"
        );

        uint realAmount = IBEP20(Constants.STONK()).balanceOf(address(this));

        require(
            IBEP20(Constants.STONK()).transferFrom(tx.origin, address(this), amount),
            "Transfer went wrong!"
        );

        realAmount = IBEP20(Constants.STONK()).balanceOf(address(this)) - realAmount;

        addStaker(realAmount, tx.origin);
    }

    /**
    *   Adds coins to the stake to let the adding address claim rewards
    */
    function addStakeFor(uint amount, address receiver) public   {
        require(
            false,
            "METHOD DEPRECATED!"
        );
    }

    /**
    *   Adds coins to the stake by buying Stonk for BNB to let the adding address claim rewards.
    *   This method saves fees as it only makes Stonks transfer once.
    */
    function purchaseStake(uint amount) payable external {
        require(msg.value == amount, "Wrong amount!");

        uint deadline = block.timestamp + 1000;
        address[] memory path = new address[](2);
        path[0] = address(Constants.WBNB());
        path[1] = address(Constants.STONK());

        uint realAmount = IBEP20(Constants.STONK()).balanceOf(address(this));

        uint[] memory amountsOut = Constants.pancakeRouter().swapExactETHForTokens{value : msg.value}(0, path, address(this), deadline);

        realAmount = IBEP20(Constants.STONK()).balanceOf(address(this)) - realAmount;

        addStaker(realAmount, tx.origin);
    }

    /**
    *   Returns all current stakers
    */
    function getStakers() external view returns (address[] memory) {
        return stakersAddresses;
    }

    /**
    *   Returns stake of given address
    */
    function getStake(address staker) external view returns (uint) {
        return stakers[staker].amount;
    }

    /**
    *   Returns unclaimed of given address
    */
    function getUnclaimedFeeOf(address staker) external view returns (uint) {
        return unclaimedFees[staker].amount;
    }

    /**
    *   Withdraws the stake of the tx.origin
    */
    function withdrawStake() external {
        require(stakers[tx.origin].amount > 0, "You have no stake!");

        require(
            IBEP20(Constants.STONK()).transfer(tx.origin, stakers[tx.origin].amount),
            "Transfer went wrong!"
        );

        removeStaker(tx.origin);
    }

    function addStaker(uint amount, address receiver) internal {
        if (stakers[receiver].exists == 0) {
            Staker memory staker;
            stakersAddresses.push(receiver);

            staker = Staker(amount, stakersAddresses.length - 1, 1);
            stakers[receiver] = staker;

        } else {
            stakers[receiver].amount = stakers[receiver].amount + amount;
        }

        totalStakedStonks += stakers[receiver].amount;
        votingToken.mint(receiver, amount);
    }

    function removeStaker(address staker) internal {
        totalStakedStonks -= stakers[staker].amount;
        votingToken.burn(staker, stakers[staker].amount);

        removeFromStakersAddresses(stakers[staker].arrayIndex);
        stakers[staker] = Staker(0, 0, 0);
    }

    function removeFromStakersAddresses(uint index) internal {
        if (stakersAddresses.length == 1) {
            delete stakersAddresses;

        } else {
            stakersAddresses[index] = stakersAddresses[stakersAddresses.length - 1];
            stakers[stakersAddresses[index]].arrayIndex = index;
            stakersAddresses.pop();
        }
    }
}
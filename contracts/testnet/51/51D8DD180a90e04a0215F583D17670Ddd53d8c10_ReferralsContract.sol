// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IERC20.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";

contract ReferralsContract is Owner, ReentrancyGuard {

    address public rewardToken;

    mapping(address => uint256) public rewardsOf; 

    mapping(address => address) public referredOf;
    uint256 public percentageForReward1; // 100 = 1%
    uint256[5] public percentageTreeForReward2; // 100 = 1%

    mapping(address => bool) public allowedList;

    // properties used to get fee
    uint256 private constant amountDivToGetFee = 10**4;

    event Set_TokenContract(
        address token
    );

    event Set_PercentageForReward1(
        uint256 newValue
    );

    event Set_PercentageTreeForReward2(
        uint256 index,
        uint256 newValue
    );

    // referred is referred of main account
    event AceptBeReferred(
        address referred,
        address main
    );

    // _type (1=reward 1 from first buy of token, 2=reward 2 from stakes) 
    event AddReward(
        uint256 rewardType,
        address recipient,
        uint256 amount
    );

    event Claim(
        address account,
        uint256 amount
    );

    constructor(address _rewardToken) {
        setTokenContract(_rewardToken);

        setPercentageForReward1(2000); // 2000 = 20%

        setPercentageTreeForReward2(0, 1000); // 1000 = 10%
        setPercentageTreeForReward2(1, 800);  // 800  = 8%
        setPercentageTreeForReward2(2, 600);  // 600  = 6%
        setPercentageTreeForReward2(3, 400);  // 400  = 4%
        setPercentageTreeForReward2(4, 200);  // 200  = 2%
    }

    function setTokenContract(address _token) public isOwner {
        rewardToken = _token;
        emit Set_TokenContract(_token);
    }

    function setPercentageForReward1(uint256 _newValue) public isOwner {
        percentageForReward1 = _newValue;
        emit Set_PercentageForReward1(_newValue);
    }

    function setPercentageTreeForReward2(uint256 _index, uint256 _newValue) public isOwner {
        percentageTreeForReward2[_index] = _newValue;
        emit Set_PercentageTreeForReward2(_index, _newValue);
    }

    function setAllowedList(address[] memory _allowedList, bool[] memory _status) public isOwner { // _status (true = allowed)
        for (uint256 i=0; i<_allowedList.length; i++) {
            allowedList[_allowedList[i]] = _status[i];
        }
    }

    function aceptBeReferredOf(address _account) external {
        require(referredOf[msg.sender] == address(0), "you are already a referral");
        referredOf[msg.sender] = _account;
        emit AceptBeReferred(msg.sender, _account);
    }

    function getTreeReferrals(address _referredAccount) public view returns(address[] memory) {
        address[] memory treeReferrals = new address[](5);
        treeReferrals[0] = referredOf[_referredAccount];
        treeReferrals[1] = referredOf[treeReferrals[0]];
        treeReferrals[2] = referredOf[treeReferrals[1]];
        treeReferrals[3] = referredOf[treeReferrals[2]];
        treeReferrals[4] = referredOf[treeReferrals[3]];
        return treeReferrals;
    }

    function calculateFee(uint256 _amount, uint256 _percentage) private pure returns(uint256){ // _percentage (100 == 1%) 
        return (_amount*_percentage)/amountDivToGetFee;
    }

    function addReward1(address _referredAccount, uint256 _amount) external returns(uint256) {
        require(allowedList[msg.sender] == true, "address not authorized to addRewards");
        uint256 fee;
        address to = referredOf[_referredAccount];
        if(to != address(0)){
            fee = calculateFee(_amount, percentageForReward1);
            rewardsOf[to] += fee;
            emit AddReward(1, to, fee);
        }
        return fee;
    }

    function addReward2(address _referredAccount, uint256 _amount) external returns(uint256) {
        require(allowedList[msg.sender] == true, "address not authorized to addRewards");
        address[] memory treeReferrals = getTreeReferrals(_referredAccount);
        uint256 totalFees;
        for (uint256 i=0; i<treeReferrals.length; i++) {
            uint256 fee = 0;
            if(treeReferrals[i] != address(0)){
                fee == calculateFee(_amount, percentageTreeForReward2[i]);
                rewardsOf[treeReferrals[i]] += fee;
                totalFees += fee;
                emit AddReward(2, treeReferrals[i], fee);
            }else{
                break;
            }
        }
        return totalFees;
    }

    function claimRewards() external nonReentrant {
        uint256 amountToClaim = rewardsOf[msg.sender];
        require(amountToClaim > 0, "amount to claim must be greater than 0");
        IERC20(rewardToken).transferFrom(getOwner(), msg.sender, amountToClaim);
        emit Claim(msg.sender, amountToClaim);
        delete rewardsOf[msg.sender];
    }
}
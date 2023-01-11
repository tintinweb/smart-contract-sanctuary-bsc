/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

/*

  _  _____  _   _  ____   ____  _   _ ____  ____  
 | |/ / _ \| \ | |/ ___| | __ )| | | / ___||  _ \ 
 | ' / | | |  \| | |  _  |  _ \| | | \___ \| | | |
 | . \ |_| | |\  | |_| | | |_) | |_| |___) | |_| |
 |_|\_\___/|_| \_|\____| |____/ \___/|____/|____/ 
                                                  
The KONG BUSD is a ROI Dapp and part of the KONG-Eco System. 
The KONG BUSD is crated by combining the great features of the existing and past ROI Dapps. 
KONG BUSD is a 100% decentralized investment platform built on the Binance Smart Chain (BEP20). 
It offers a variable yield % of 1% to 4% with a maximum profit of 300% of the total deposited amount.

Visit website for more details: https://kongbusd.finance
*/

pragma solidity ^0.8.15;

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ERC721TokenReceiver
{
  function onERC721Received(address, address, uint256, bytes calldata) external returns(bytes4);
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface KongBusdV2{
    function getUserAllStakeDetailsByAddress(address _userAddress) external view returns(userStakeV2[] memory);
    function stake(uint256 _amount, address _referrer) external returns (bool);
    function unstake(uint256 _stakeId) external returns (bool);
    function claim(uint256 _stakeId)  external returns (bool);
    function compound(uint256 _stakeId) external returns (bool);
    function setActionedTime(uint256 _stakeId, uint256 _days, address _userAddress)  external;
    function setNextActionTime(uint256 _stakeId, uint256 _days, address _userAddress)  external;
    function getClaimableBalance(uint256 _stakeId) external view returns(uint256);
}

interface KongPoolMaster{
    function createPool(uint256 _stakeAmount) external;
}

struct userStakeV2{
    uint256 id;
    uint256 roi;
    uint256 stakeAmount;
    uint256 totalClaimed;
    uint256 totalCompounded;
    uint256 lastActionedTime;
    uint256 nextActionTime;
    uint256 status; //0 : Unstaked, 1 : Staked
    address referrer;
    address owner;
    uint256 createdTime;
}

contract babyKongPool is IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        return this.onERC721Received.selector;
    }

    struct babyStake{
        uint256 id;
        uint256 totalClaimed;
        uint256 nextClaimTime;
        uint256 lastClaimedTime;
        uint256 status; //0 = unstaked, 1 = active
        address owner;
        uint256 createdTime;
    }

    address public busdAddress = 0xAe12F7EeA8FF55383109E0B28B95300082c5f78e;
    IERC20 busd = IERC20(busdAddress);

    address public kongV2Address = 0xe7D3fC806fb28016D0865f366281bBFF2Be85438;
    KongBusdV2 kongV2 = KongBusdV2(kongV2Address);

    address public KongPoolMasterAddress;
    KongPoolMaster poolMaster;

    address public owner;
    uint256 public stakeAmount;
    uint256 public createdTime;
    uint256 public totalBabyStakes;
    uint256 public totalStaked;
    uint256 public totalClaimed;
    uint256 public totalCompounded;

    uint256 public stakeIndex;
    uint256 public nextCycleAction; //0 : compound, 1 : claim
    uint256 public nextActionTime;
    address public lastWinnerAddress;
    address public winnerAddress;
    address public lastCompounder;

    uint256[] public unstakedIds;
    uint256[] public activeStakeIds;
    uint256[] public winnerIds;
    uint256[] public pendingWinnerIds;

    mapping (uint256 => babyStake) public userStakesById;
    mapping (address => babyStake) public userStakesByAddress;
    mapping (address => uint256) public userStakeIdByAddress;
    mapping (address => bool) public isWon;
    mapping (address => bool) public isStaked;

    constructor(address _creatorAddress, uint256 _stakeAmount, address _poolMasterAddress){
        owner = _creatorAddress;
        KongPoolMasterAddress = _poolMasterAddress;
        poolMaster = KongPoolMaster(KongPoolMasterAddress);

        stakeAmount = _stakeAmount;
        nextCycleAction = 0; // compounding after 1 day
        nextActionTime =block.timestamp + 1 days;
        createdTime = block.timestamp;
    }
    
    function createNewPool() public {
        poolMaster.createPool(stakeAmount);
    }

    function stake() external returns (bool) {
        //require(isStaked[msg.sender] == false,"You can not stake more than once in same group pool");
        require(totalBabyStakes <= 10,"Maximum 10 members can join in one group pool");
        uint256 _amount = 10 ether;
        address _referrer = owner;
        babyStake memory userStakeDetails;
        uint256 stakeId = stakeIndex++;
        userStakeDetails.id = stakeId;
        userStakeDetails.nextClaimTime = block.timestamp + 7 days;
        userStakeDetails.status = 1;
        userStakeDetails.owner = msg.sender;
        userStakeDetails.createdTime = block.timestamp;
        userStakesById[stakeId] = userStakeDetails;
        userStakesByAddress[msg.sender] = userStakeDetails;
        userStakeIdByAddress[msg.sender] = stakeId;
        activeStakeIds.push(stakeId);
        
        isStaked[msg.sender] = true;
        totalBabyStakes++;
        totalStaked += _amount;

        if(totalBabyStakes == 10){
            poolMaster.createPool(stakeAmount);
        }
        
        require(busd.allowance(msg.sender, address(this)) >= _amount,"Not enough BUSD approved for transfer"); 
        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Transfer failed.");
        busd.approve(kongV2Address,_amount);
        kongV2.stake(_amount, _referrer);
        
        return true;
    }

    function unstake() public {
        require(isWon[msg.sender] == false,"You can not stake after winning");
        uint256 stakeId = userStakeIdByAddress[msg.sender];
        babyStake memory userStakeDetails = userStakesById[stakeId];
        userStakeDetails.status = 0;
        userStakesById[stakeId] = userStakeDetails;
        unstakedIds.push(stakeId);

        userStakeV2[] memory allBabyStakes = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < allBabyStakes.length; i++){
            if(allBabyStakes[i].status == 1){
                kongV2.unstake(allBabyStakes[i].id);
                break;
            }
        }
        setActiveStakes();
        setPendingWinners();

        isStaked[msg.sender] = false;

        bool success = busd.transfer(msg.sender, busd.balanceOf(address(this)));
        require(success, "BUSD Transfer failed.");
    }

    function setActiveStakes() public {
        //uint256[] memory tempArray;
        delete activeStakeIds;
        uint256 unstakedflag;
        for(uint256 i=0; i < totalBabyStakes; i++){
            unstakedflag = 0;
            for(uint256 j=0; j < unstakedIds.length; j++){
                if(i==unstakedIds[j]){
                    unstakedflag = 1;
                }
            }
            if(unstakedflag == 0){
                activeStakeIds.push(i);
            }
        }
    }

    function setPendingWinners() public {    
        delete pendingWinnerIds;
        uint256 wonflag;
        for(uint256 i=0; i < activeStakeIds.length; i++){
            wonflag = 0;
            for(uint256 j=0; j < winnerIds.length; j++){
                if(i==winnerIds[j]){
                    wonflag = 1;
                }
            }
            if(wonflag == 0){
                activeStakeIds.push(i);
            }
        }
    }

    function getActiveStakes() public view returns(uint256[] memory){
       return activeStakeIds;
    }

    function setNextWinner() internal {
        for (uint256 i = 0; i < pendingWinnerIds.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp))) % (pendingWinnerIds.length - i);
            uint256 temp = pendingWinnerIds[n];
            pendingWinnerIds[n] = pendingWinnerIds[i];
            pendingWinnerIds[i] = temp;
        }
        lastWinnerAddress = winnerAddress;
        uint256 winnerId = pendingWinnerIds[0];
        babyStake memory userStakeDetails = userStakesById[winnerId];
        winnerAddress = userStakeDetails.owner;
        isWon[winnerAddress] = true;

        if(winnerIds.length == activeStakeIds.length){
            delete winnerIds;
        }else{
            winnerIds.push(winnerId);
        }

        setPendingWinners();
    }

    function getTotalClaimableBalance() public view returns(uint256){    
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));
        uint256 totalClaimableBalance;
        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                totalClaimableBalance += kongV2.getClaimableBalance(userStakesList[i].id);
            }
        }

        return totalClaimableBalance;
    }

    function getAllBabyStakes() external view returns(userStakeV2[] memory){
        return kongV2.getUserAllStakeDetailsByAddress(address(this));
    }

    function claimAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 1,"Claiming not available" );
        require(msg.sender == winnerAddress,"You are not eligibale to claim");
        nextActionTime =block.timestamp + 1 days;
        nextCycleAction = 0;

        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.claim(userStakesList[i].id);
            }
        }

        bool success = busd.transfer(msg.sender, busd.balanceOf(address(this)));
        require(success, "BUSD Transfer failed.");
    }

    function compoundAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 0,"Compounding not available" );
        nextActionTime =block.timestamp + 1 days;
        nextCycleAction = 1;

        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.compound(userStakesList[i].id);
            }
        }
    
        lastCompounder = msg.sender;
        setNextWinner();
    }
    //Testing functions

    function setActionedTime(uint256 _stakeId, uint256 _days, address _userAddress)  public {
        kongV2.setActionedTime(_stakeId,_days, _userAddress);
    }

    function setNextActionTime(uint256 _stakeId, uint256 _days, address _userAddress)  public {
       kongV2.setNextActionTime(_stakeId,_days, _userAddress);
    }
    
    function setPoolNextActionedTime(uint256 _action, uint256 _days)  public {
        nextActionTime = block.timestamp + (_days * 86400);
        nextCycleAction = _action;
    }

    receive() external payable {}
}
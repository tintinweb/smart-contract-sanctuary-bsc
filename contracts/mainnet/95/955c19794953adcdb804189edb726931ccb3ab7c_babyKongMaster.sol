/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT

/*

  _  _____  _   _  ____   ____  _   _ ____  ____  
 | |/ / _ \| \ | |/ ___| | __ )| | | / ___||  _ \ 
 | ' / | | |  \| | |  _  |  _ \| | | \___ \| | | |
 | . \ |_| | |\  | |_| | | |_) | |_| |___) | |_| |
 |_|\_\___/|_| \_|\____| |____/ \___/|____/|____/ 
                                                  
This will be our new group staking pools project Baby Kong to support our main KONGBUSD V2 ongoing project.
We believe this new group staking concept is new and innovative to support our on going V2 ROI DAPP.

It’s a simple concept where upto 10 people stake together in one pool and win huge collective dividends every alternate day for total group staked value instead daily small rewards

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

contract babyKongMaster is IERC721Receiver{
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        return this.onERC721Received.selector;
    }

    babyKongPool public babyStakePool;

    struct babyPool{
        uint256 id;
        address poolAddress;
        uint256 stakeAmount;
        uint256 createdTime;
    }

    babyPool[] public babyPoolArray;
    address[] public babyPool25AddressArray;
    address[] public babyPool50AddressArray;
    address[] public babyPool100AddressArray;
    address[] public babyPool250AddressArray;
    address[] public babyPool500AddressArray;
    address[] public babyPool1000AddressArray;
   
    address public owner;
    uint256 public poolIndex;
    address [] public babyStakeOwners;
    
    mapping (uint256 => babyPool) public poolDetailsById;
    mapping (address => bool) public isAuthorized;

    modifier onlyAuthorized {
        require(msg.sender == owner || isAuthorized[msg.sender] == true);
        _;
    }

    constructor(){
        owner = msg.sender;
        isAuthorized[owner] = true;

        createPool(25 ether);  
    }

    function createPool(uint256 _stakeAmount) public onlyAuthorized {
        require(_stakeAmount == 25 ether || _stakeAmount == 50 ether || _stakeAmount == 100 ether || _stakeAmount == 250 ether || _stakeAmount == 500 ether || _stakeAmount == 1000 ether,"Invalid pool amount");
        babyStakePool = new babyKongPool(owner,_stakeAmount,address(this));
        babyPool memory poolDetails;
        isAuthorized[address(babyStakePool)] = true;
        uint256 poolId = poolIndex++;
        poolDetails.id = poolId;
        poolDetails.poolAddress = address(babyStakePool);
        poolDetails.stakeAmount = _stakeAmount;
        poolDetails.createdTime = block.timestamp;
        poolDetailsById[poolId] = poolDetails;
        babyPoolArray.push(poolDetails);

        if(_stakeAmount == 25 ether){
            babyPool25AddressArray.push(address(babyStakePool));
        }else if(_stakeAmount == 50 ether){
            babyPool50AddressArray.push(address(babyStakePool));
        }else if(_stakeAmount == 100 ether){
            babyPool100AddressArray.push(address(babyStakePool));
        }else if(_stakeAmount == 250 ether){
            babyPool250AddressArray.push(address(babyStakePool));
        }else if(_stakeAmount == 500 ether){
            babyPool500AddressArray.push(address(babyStakePool));
        }else if(_stakeAmount == 1000 ether){
            babyPool1000AddressArray.push(address(babyStakePool));
        }
    }
    
    function getPools() public view returns(address[] memory, address[] memory, address[] memory, address[] memory, address[] memory, address[] memory){
        return (babyPool25AddressArray,babyPool50AddressArray,babyPool100AddressArray,babyPool250AddressArray,babyPool500AddressArray,babyPool1000AddressArray);
    }

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
        uint256 lastClaimedTime;
        uint256 status; //0 = unstaked, 1 = active
        address owner;
        uint256 createdTime;
    }
    babyStake[] public babyStakesArray;

    address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IERC20 busd = IERC20(busdAddress);

    address public kongV2Address = 0x51477431DBb027c95aD936CaC8a8ECC4ADEe2a5e;
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
        
        createdTime = block.timestamp;
    }
    
    function stake() external returns (bool) {
        require(isStaked[msg.sender] == false,"You can not stake more than once in same group pool");
        require(totalBabyStakes <= 10,"Maximum 10 members can join in one group pool");
        uint256 _amount = stakeAmount;
        address _referrer = owner;
        babyStake memory userStakeDetails;
        uint256 stakeId = stakeIndex++;
        userStakeDetails.id = stakeId;
        userStakeDetails.status = 1;
        userStakeDetails.owner = msg.sender;
        userStakeDetails.createdTime = block.timestamp;
        babyStakesArray.push(userStakeDetails);
        userStakesById[stakeId] = userStakeDetails;
        userStakesByAddress[msg.sender] = userStakeDetails;
        userStakeIdByAddress[msg.sender] = stakeId;
        activeStakeIds.push(stakeId);
        pendingWinnerIds.push(stakeId);
        isStaked[msg.sender] = true;

        if(totalBabyStakes == 0){
            nextActionTime =block.timestamp + 1 days;
        }

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
        updateStakeArray(stakeId);
        unstakedIds.push(stakeId);

        userStakeV2[] memory allBabyStakes = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < allBabyStakes.length; i++){
            if(allBabyStakes[i].status == 1){
                kongV2.unstake(allBabyStakes[i].id);
                break;
            }
        }
        totalBabyStakes--;
        setActiveStakes();
        setPendingWinners();

        isStaked[msg.sender] = false;

        bool success = busd.transfer(msg.sender, busd.balanceOf(address(this)));
        require(success, "BUSD Transfer failed.");
    }

    function setActiveStakes() internal {
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

    function setPendingWinners() internal {    
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
                pendingWinnerIds.push(i);
            }
        }
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

    function getActiveStakeIds() public view returns(uint256[] memory){
       return activeStakeIds;
    }

    function getPendingWinnerIds() public view returns(uint256[] memory){
       return pendingWinnerIds;
    }

    function getWinnerIds() public view returns(uint256[] memory){
       return winnerIds;
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

    function getAllBabyStakesArray() external view returns(babyStake[] memory){
        return babyStakesArray;
    }

    function getClaimableStakes() public view returns(uint256){
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));
        uint256 claimableStakes;
        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                claimableStakes++;
            }
        }
        return claimableStakes;
    }

    function claimAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 1,"Claiming not available" );
        require(msg.sender == winnerAddress,"You are not eligibale to claim");
       
        nextActionTime =block.timestamp + 1 days;
        nextCycleAction = 0;
        uint256 totalClaimableBalance = getTotalClaimableBalance();
        
        uint256 stakeId = userStakeIdByAddress[winnerAddress];
        babyStake memory userStakeDetails = userStakesById[stakeId];
        userStakeDetails.totalClaimed = totalClaimableBalance;
        userStakesById[stakeId] = userStakeDetails;
        updateStakeArray(stakeId);

        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.claim(userStakesList[i].id);
            }
        }
        totalClaimed += totalClaimableBalance;
        bool success = busd.transfer(msg.sender, busd.balanceOf(address(this)));
        require(success, "BUSD Transfer failed.");
    }

    function compoundAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 0,"Compounding not available" );
        nextActionTime =block.timestamp + 1 days;
        nextCycleAction = 1;
        uint256 totalCompoundableBalance = getTotalClaimableBalance();
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.compound(userStakesList[i].id);
            }
        }
        totalCompounded += totalCompoundableBalance;
        lastCompounder = msg.sender;
        setNextWinner();
    }

    function updateStakeArray(uint256 _stakeId) internal {
        for(uint i = 0; i < babyStakesArray.length; i++){
            babyStake memory userStakeFromArrayDetails = userStakesById[i];
            if(userStakeFromArrayDetails.id == _stakeId){
                babyStakesArray[i] = userStakesById[_stakeId];
            }
        }
    }
       
    receive() external payable {}
}
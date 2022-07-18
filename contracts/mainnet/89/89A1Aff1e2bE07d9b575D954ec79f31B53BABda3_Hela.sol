/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 id) external view returns (address);
    function limit() external view returns (uint256);
    function tokenOfOwnerByIndex(address account, uint256 index) external view returns (uint256);
}

interface invite {
    function getInviteIsValid(uint256, address) external view returns (bool, bool, bool, address);
    function setValidInvite(address) external;
    function restart(uint256) external;
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
  
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "e0");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// Usdt pool
contract usdtPool {
    using SafeMath for uint256;
    address public pledgeAddress;
    address public usdt;
    address public token;

    function sell(uint256 _amount, uint256 _price, address _user) external {
        require(pledgeAddress == msg.sender,"No permission sell");
        uint256 num = _amount.mul(_price).div(1e18).mul(90).div(100);
        uint256 poolBalance = IERC20(usdt).balanceOf(address(this));
        require(poolBalance >= num,"Insufficient balance of currency pool");
        TransferHelper.safeTransfer(usdt, _user, num);
    }

    function tokenApprove() external {
        require(pledgeAddress == msg.sender,"No permission tokenApprove");
        TransferHelper.safeApprove(usdt, pledgeAddress, 1e21);  // 1000USDT
    }

    constructor(address _xtoken, address _usdt, address _pledge) {
        token = _xtoken;
        usdt = _usdt;
        pledgeAddress = _pledge;
    }

}

// Pool to be allocated
contract allocated {
    address public token;
    address public pledgeAddress;

    function approveAllocated() public {
        TransferHelper.safeApprove(token, pledgeAddress, 2**256-1);
    }

    constructor(address _xtoken, address _pledge) {
        token = _xtoken;
        pledgeAddress = _pledge;
    }

}

contract Hela is ReentrancyGuard {
    using SafeMath for uint256;
    address public owner;

    uint256 fee = 1e15;
    address public feeAddress = 0xaD7A3c9c46b79b0704E21Cc1057dC68ac3671313;
 
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public token = 0xF4bc9AFBFaaDd328c2e6D711fbD88B87caeC2dEE;

    address public poolAddress;
    address public tokenPool;

    address public allocatedAddress;

    address public erc721Address = 0xC8B16a787AE6c557771F26B1a4C68ba91CA454da;

    address public inviteAddress = 0x7Ef5Fb331A691E2b61376169C915db53CEFB98ba;

    address[5] public poolList;

    uint256 _amount = 1e20;
   
    function setFeeAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        feeAddress = _token;
    }
    function setUsdtAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        usdt = _token;
    }
    function setTokenAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        token = _token;
    }
    function setPoolAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        poolAddress = _token;
        tokenPool = _token;
    }
    function setAllocatedAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        allocatedAddress = _token;
    }
    function setErc721Address(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        erc721Address = _token;
    }
    function setInviteAddress(address _token) external {
        require(owner == msg.sender,"No permission to modify");
        inviteAddress = _token;
    }
    function setPoolList(address pool1, address pool2, address pool3, address pool4, address pool5) external {
        require(owner == msg.sender,"No permission to modify");
        poolList[0] = pool1;
        poolList[1] = pool2;
        poolList[2] = pool3;
        poolList[3] = pool4;
        poolList[4] = pool5;
    }

    // Discard permissions after project deployment
    function discardPermissions() external {
        require(owner == msg.sender,"No permission to modify");
        owner = address(0);
    }
    
    // Purchase polling times
    uint256 public polling = 0;
    // Current purchase order No
    uint256 public index = 0;
    // Purchase start time
    uint256 public timeStart = block.timestamp;
    // Purchase end time
    uint256 public timeEnd = timeStart + 2592000;
    // Priority purchase end time
    uint256 public firstTimeEnd = timeStart + 1800;
    // Restart the number of super awards usdt
    uint256 public jackpotUsdt;
    // NFT number of usdt and tokens to be allocated
    uint256 public nftUsdt;
    uint256 public nftToken;
    // Number of tokens to be allocated to the previous order
    mapping(uint256 => uint256[]) public fatherData;
    // Purchase list
    mapping(uint256 => mapping(uint256 => address)) public ordersList;
    mapping(uint256 => mapping(address => uint256)) public ordersData;
    // Number of purchases per round
    mapping(uint256 => uint256) public quantity;
    // NFT purchase record
    mapping(uint256 => uint) public nftLists;
    // Purchase fixed price for the first time after restart
    uint256 public fixedPrice = 0;

    uint256 total = 1e30;
    // Set purchase start time
    function setTimeStart(uint256 _time) external {
        require(owner == msg.sender,"No permission");
        timeStart = _time;
        timeEnd = timeStart + 2592000;
        firstTimeEnd = timeStart + 1800;
    }
    
    event purchaseList(uint,uint,uint256,uint,address);
    function purchase() external payable nonReentrant {
        require(block.timestamp > timeStart,"Not started");
        require(timeEnd > block.timestamp,"Scheduling has ended");
        if(firstTimeEnd > block.timestamp){
            require(queryAuthority(),"No priority");
            // The addresses with NFT in the first round have priority, and the number of purchases is the number of NFT
            if(polling == 0){
                setNft();
            }
        }
        
        // Purchase fixed price for the first time after restart
        if(polling != 0 && index == 0){
            uint256 lastPolling = polling - 1;
            fixedPrice = poolPrice(poolList[lastPolling%poolList.length]);
        }

        index += 1;
        
        TransferHelper.safeTransferETH(feeAddress, fee);
        TransferHelper.safeTransferFrom(usdt, address(msg.sender), address(this), _amount);
        uint256 usdtBalance = IERC20(usdt).balanceOf(poolAddress).add(_amount.mul(25).div(100));
        uint256 totalToken = returnToken(_amount, usdtBalance);
        uint256 tokenNum = totalToken.mul(20).div(100);
        // Record the next order and I can get the number of tokens
        fatherData[polling].push(tokenNum);
        
        // Query whether you have purchased. If not, change your status
        (bool isArrange, bool effective, bool upisArrange, address up) = invite(inviteAddress).getInviteIsValid(polling, msg.sender);
        if(isArrange == false) {
            invite(inviteAddress).setValidInvite(msg.sender);
        }
        
        uint256 proportion;
        if(index != 1){
            // Assign a token worth 20u to the previous order
            TransferHelper.safeTransferFrom(token, allocatedAddress, ordersList[polling][index-1], fatherData[polling][index-2]);
            TransferHelper.safeTransfer(usdt, ordersList[polling][index-1], _amount.mul(20).div(100));
            // Allocate 52%u to the U pool (25% + 5%nft +2% super node +20% exchange token)
            proportion = 52;
        } else {
            // The first order allocates 70% u to the U pool (25% + 5%nft + 2% super node + 40% exchange token)
            proportion = 72;
        }
        
        if(up != address(0) && upisArrange){
            // Assign 10%u to the recommender
            TransferHelper.safeTransfer(usdt, up, _amount.mul(10).div(100));
            uint256 tokenVal = totalToken.mul(10).div(100);
            TransferHelper.safeTransferFrom(token, allocatedAddress, up, tokenVal);
            proportion += 10;
        } else {
            proportion += 20;
        }

        TransferHelper.safeTransfer(usdt, poolAddress, _amount.mul(proportion).div(100));

        // Contract allocation 1% to restart the bonus pool
        jackpotUsdt += _amount.mul(1).div(100);

        uint256 nftVal = totalToken.mul(5).div(100);
        nftUsdt += _amount.mul(5).div(100);
        nftToken += nftVal;
        
        TransferHelper.safeTransferFrom(token, allocatedAddress, address(this), nftVal);

        TransferHelper.safeTransfer(usdt, inviteAddress, _amount.mul(2).div(100));
        uint256 inviteVal = totalToken.mul(2).div(100);
        TransferHelper.safeTransferFrom(token, allocatedAddress, inviteAddress, inviteVal);
        
        if(timeEnd + 604800 > block.timestamp + 2592000){
            timeEnd = block.timestamp + 2592000;
        } else {
            timeEnd += 604800;
        }

        emit purchaseList(polling, index, fatherData[polling][index-1], block.timestamp, msg.sender);

        ordersList[polling][index] = address(msg.sender);
        ordersData[polling][msg.sender] = index;
        
    }

    function setNft() internal {
        uint256 nftBalance = IERC721(erc721Address).balanceOf(msg.sender);
        for(uint i=0; i<nftBalance; i++){
            uint256 id = IERC721(erc721Address).tokenOfOwnerByIndex(msg.sender, i);
            if(nftLists[id] < 4) {
                nftLists[id] += 1;
                return;
            }
        }
    }
    // Determine whether priority can be given
    function queryAuthority() public view returns (bool) {
        if(polling == 0){
            uint256 nftBalance = IERC721(erc721Address).balanceOf(msg.sender);
            if(nftBalance != 0){
                for(uint i=0; i<nftBalance; i++){
                    uint256 id = IERC721(erc721Address).tokenOfOwnerByIndex(msg.sender, i);
                    if(nftLists[id] < 4) {
                        return true;
                    }
                }
            }
            return false;
        } else {
            if(quantity[polling-1] - ordersData[polling-1][msg.sender] <= 10){
                return false;
            }

            if(quantity[polling-1] - ordersData[polling-1][msg.sender] <= 5000 && ordersData[polling-1][msg.sender] != 0){
                if(ordersData[polling][msg.sender] == 0){
                    return true;
                }
            }

        }
        
        return false;
        
    }

    function returnToken(uint256 _usdtAmount, uint256 _usdtBalance) public view returns (uint256) {
        uint256 allocatedBalance = IERC20(token).balanceOf(allocatedAddress);
        uint256 num = _usdtAmount.mul(1e18).div(_usdtBalance.mul(1e18).div(total.sub(allocatedBalance)));
        return num;
    }

    struct award {
        address _user;
    }
    mapping(uint256 => award[]) public resetAward;
    mapping(uint256 => uint256) public resetBonus;
    mapping(uint256 => uint256) public resetIndex;

    function reset() public nonReentrant {
        require(timeEnd < block.timestamp,"The scheduling time is not over");
        timeStart = block.timestamp + 172800;
        timeEnd = timeStart + 2592000;
        firstTimeEnd = timeStart + 1800;
        fixedPrice = 0;

        if(index <= 10 && index != 0){
            for(uint256 i = 1; i <= index; i++){
                TransferHelper.safeTransfer(usdt, ordersList[polling][i], jackpotUsdt.div(index));
                award memory newData = award({
                    _user:ordersList[polling][i]
                });
                resetAward[polling].push(newData);
            }
            resetBonus[polling] = jackpotUsdt.div(index);
            resetIndex[polling] = index;
        } else if(index != 0) {
            for(uint256 i = index-9; i <= index; i++){
                TransferHelper.safeTransfer(usdt, ordersList[polling][i], jackpotUsdt.div(10));
                award memory newData = award({
                    _user:ordersList[polling][i]
                });
                resetAward[polling].push(newData);
            }
            resetBonus[polling] = jackpotUsdt.div(10);
            resetIndex[polling] = index;
        }

        quantity[polling] = index;
        polling += 1;
        index = 0;
        jackpotUsdt = 0;
        
        resetPool(poolList[polling%poolList.length]);
        allocated(allocatedAddress).approveAllocated();
        
        // Switch currency pool
        poolAddress = poolList[polling%poolList.length];

        // Invitation reward allocation
        invite(inviteAddress).restart(polling);

    }

    function resetPool(address _newPool) internal {
        uint256 account = 1e20;
        uint256 usdtBalance = IERC20(usdt).balanceOf(poolAddress);
        uint256 newUsdtBalance = IERC20(usdt).balanceOf(_newPool);
        usdtPool(poolAddress).tokenApprove();
        // Transfer 1000u to new u pool
        if(newUsdtBalance < account){
            // Number of new u pool transfers required
            uint256 num = account.sub(newUsdtBalance);
            if(usdtBalance > num){
                TransferHelper.safeTransferFrom(usdt, poolAddress, _newPool, num);
            } else {
                TransferHelper.safeTransferFrom(usdt, poolAddress, _newPool, usdtBalance);
            }
        }
    }

    struct priceData {
        address _poolAddress;
        uint256 _price;
    }
    function getPrice() public view returns (priceData memory) {
        uint256 lastPolling;
        if(polling != 0){
            lastPolling = polling - 1;
        }
        // Current currency pool price
        uint256 currentPrice = poolPrice(poolAddress);
        uint256 currentUsdtBalance = IERC20(usdt).balanceOf(poolAddress);
        uint256 lastUsdtBalance = IERC20(usdt).balanceOf(poolList[lastPolling%poolList.length]);
        // Last round currency pool price
        uint256 lastPrice = poolPrice(poolList[lastPolling%poolList.length]);
        if(fixedPrice != 0) {
            lastPrice = fixedPrice;
        }

        if(currentPrice > lastPrice){
            if(currentUsdtBalance > 1e15) {
                priceData memory price = priceData({_price:currentPrice,_poolAddress:poolAddress});
                return price;
            } else {
                priceData memory price = priceData({_price:lastPrice,_poolAddress:poolList[lastPolling%poolList.length]});
                return price;
            }
        } else {
            if(lastUsdtBalance > 1e15) {
                priceData memory price = priceData({_price:lastPrice,_poolAddress:poolList[lastPolling%poolList.length]});
                return price;
            } else {
                priceData memory price = priceData({_price:currentPrice,_poolAddress:poolAddress});
                return price;
            }
        }
    }

    function poolPrice(address _poolAddress) public view returns (uint256) {
        uint256 allocatedBalance = IERC20(token).balanceOf(allocatedAddress);
        uint256 tokenBalance = total.sub(allocatedBalance);
        uint256 usdtBalance = IERC20(usdt).balanceOf(_poolAddress);
        return usdtBalance.mul(1e18).div(tokenBalance);
    }

    // The user sells the token and gets usdt
    event sellTokenList(uint,uint,uint,address);
    function sellToken(uint256 amount) external payable nonReentrant {
        uint256 tokenBalance = IERC20(token).balanceOf(msg.sender);
        require(tokenBalance >= amount,"Insufficient Balance");
        priceData memory price = getPrice();
        TransferHelper.safeTransferETH(feeAddress, fee);
        usdtPool(price._poolAddress).sell(amount, price._price, msg.sender);
        TransferHelper.safeTransferFrom(token, msg.sender, allocatedAddress, amount);
        emit sellTokenList(amount, price._price, block.timestamp, msg.sender);
    }

    function getAwardRecord(uint256 _index) external view returns (award[] memory){
        return resetAward[_index];
    }
    
    // Deposit information of each ID
    struct data {
        uint256 received_usdt; 
        uint256 not_usdt; 
        uint256 received_token;
        uint256 not_token;
    }

    mapping(uint256 => data) userMoney;

    function getUserMoney(uint256 _id) public view returns (data memory) {
        uint256 limit = IERC721(erc721Address).limit();
        uint256 not_usdt = nftUsdt.div(limit).sub(userMoney[_id].received_usdt);
        uint256 not_token = nftToken.div(limit).sub(userMoney[_id].received_token);
        data memory userData = data({
            not_usdt:not_usdt,
            received_usdt:userMoney[_id].received_usdt,
            not_token:not_token,
            received_token:userMoney[_id].received_token
        });
        return userData;
    }
    
    event nftExtractList(uint,uint,uint,uint);
    function nftExtract(uint256 _id) external payable nonReentrant {
        address _address = IERC721(erc721Address).ownerOf(_id);
        require(_address == msg.sender,"No permission nftExtract");
        data memory userData = getUserMoney(_id);
        require(userData.not_usdt > 0,"There is no available limit");
        require(userData.not_token > 0,"There is no available limit");
        TransferHelper.safeTransferETH(feeAddress, fee);
        TransferHelper.safeTransfer(usdt, msg.sender, userData.not_usdt);
        TransferHelper.safeTransfer(token, msg.sender, userData.not_token);
        userMoney[_id].received_usdt += userData.not_usdt;
        userMoney[_id].received_token += userData.not_token;
        emit nftExtractList(userData.not_usdt, userData.not_token, block.timestamp, _id);
        
    }

    function getTime() external view returns (uint256) {
        if(block.timestamp < timeStart) {
            return 0; // List arrangement not started
        } else if(block.timestamp < firstTimeEnd) {
            return 1;  // Priority scheduling time
        } else if(block.timestamp < timeEnd) {
            return 2;  // Normal scheduling time
        } else {
            return 3;  // End of order arrangement
        }

    }

    constructor() {
        owner = msg.sender;
    }
}
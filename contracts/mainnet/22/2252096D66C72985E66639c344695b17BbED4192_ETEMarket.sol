/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint8);
}
interface IERC721 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function mint(address to) external returns(uint256); 
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context, including the
  */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract ETEMarket is Context, Ownable {
    event BalanceUpdate(uint256 value);
    // USDT合约指针
    IERC20 public _usdtContract;  
    // IFO合约指针
    IERC20 public _ifoContract;  
    // 721合约指针
    IERC721 public _nftContract;  
    address private _ifoHolder; 
    
    uint256 private _price;
    uint256 public _nftCount;
    uint256 private _buyAmountLimit; // 每次的认购金额
    uint256 public _nftReward; // 给NFT 持有者的分

    struct UserInfo {
        uint256 totalDeposit; // 总存的usdt金额
        uint256 totalReferCount; // 总的推荐人数
        address parent; // 上级      
    }

    mapping(address => UserInfo) private _userInfo;
    mapping(uint256 => uint256) private _tokenIdTotalClaim;
    address[] private _allUserAddress; // 方便之后遍历

    
    function setPrice(uint256 price) public onlyOwner{
        _price = price;
    }

    function getPrice() public view returns(uint256){
        return _price;
    }

    function setBuyAmountLimit(uint256 amount) public onlyOwner{
        _buyAmountLimit = amount;
    }

    function getBuyAmountLimit() public view returns(uint256){
        return _buyAmountLimit;
    }
 
    function setIfoContract(address ifoContractAddress) public onlyOwner{        
        _ifoContract = IERC20(ifoContractAddress);
    }
 
    function setIfoHolder(address ifoHolder) public onlyOwner{        
        _ifoHolder = ifoHolder;
    }    
 
    function setNftContract(address nftContractAddress) public onlyOwner{        
        _nftContract = IERC721(nftContractAddress);
    }

    function getUserInfo(address userAddress) public view returns (UserInfo memory) {
        require(msg.sender == owner() || msg.sender == userAddress, "ETE: only owner can call this function");
        return _userInfo[userAddress];
    }

    // 参与地址数
    function getUserCount() public view returns(uint256){
        require(msg.sender == owner(), "ETE: only owner can call this function");
        return _allUserAddress.length;
    }  

    // 取出所有用户地址
    function getAllUserAddress(uint offset, uint pageSize) public onlyOwner view returns(address[] memory) {
        require(msg.sender == owner(), "ETE: only owner can call this function");
        require(offset < _allUserAddress.length, "ETE: offset should less than user count");
        require(pageSize < 200, "ETE: pageSize should less than 200");
        uint i;
        address[] memory users = new address[](pageSize); 
        uint limit = _allUserAddress.length < (offset + pageSize) ? _allUserAddress.length : (offset + pageSize);
        for(i=offset; i<limit; i++){
            users[i] = _allUserAddress[i];
        }
        return users;
    }

    // 取出所有用户信息
    function getAllUserInfo(uint offset, uint pageSize) public onlyOwner view returns(UserInfo[] memory) {
        require(msg.sender == owner(), "ETE: only owner can call this function");
        require(offset < _allUserAddress.length, "ETE: offset should less than user count");
        require(pageSize < 200, "ETE: pageSize should less than 200");
        UserInfo[] memory users = new UserInfo[](pageSize); 
        uint i;
        uint limit = _allUserAddress.length < (offset + pageSize) ? _allUserAddress.length : (offset + pageSize);
        for(i=offset; i<limit; i++){
            users[i] = _userInfo[_allUserAddress[i]];
        }
        return users;
    }

    // 购买U
    function buy(address parent) public  returns (bool success) {
        UserInfo storage userInfo = _userInfo[msg.sender];
        UserInfo storage parentInfo = _userInfo[parent];
        uint256 amount = _buyAmountLimit;    

        _usdtContract.transferFrom(msg.sender, _ifoHolder, amount); // 扣除sender的USDT        
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了
        // 只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(parent != address(0) && userInfo.parent == address(0) && parent != msg.sender && parentInfo.parent != msg.sender){
            userInfo.parent = parent;
            // parent地址地址没有认购过，而且没有拿过推荐奖励，就加到新用户数组里
            if(parentInfo.totalDeposit == 0 && parentInfo.totalReferCount == 0) _allUserAddress.push(parent);

            parentInfo.totalReferCount += 1; // 推荐人数加1 
            if(_nftCount < 88888 && parentInfo.totalReferCount > 0 && parentInfo.totalReferCount % 10 == 0){
                // 每次够10个，发送NFT卡
                _nftCount = _nftContract.mint(parent);
            }
        }
        
        if(userInfo.totalDeposit == 0) {
            // 第一次认购, 放到用户数组里
            _allUserAddress.push(msg.sender);
        }         

        if(userInfo.parent != address(0)){   
            address parentAddress = userInfo.parent;         
            parentInfo = _userInfo[parentAddress]; // 上级
            if(parentInfo.totalReferCount > 10){
                _usdtContract.transferFrom(_ifoHolder, parentAddress, amount*30/100); // 直推拿30%奖励
            }else{
                _usdtContract.transferFrom(_ifoHolder, parentAddress, amount*15/100); // 直推拿15%奖励
            }
            
            if(parentInfo.parent != address(0)){
                parentAddress = parentInfo.parent;
                parentInfo = _userInfo[parentAddress]; // 上上级
                if(parentInfo.totalReferCount > 10){
                    _usdtContract.transferFrom(_ifoHolder, parentAddress, amount/5); // 直推拿20%奖励
                }else{
                    _usdtContract.transferFrom(_ifoHolder, parentAddress, amount/10); // 直推拿10%奖励
                }
            }
        }
        _ifoContract.transferFrom(_ifoHolder, msg.sender, amount * 10000/_price);  
        userInfo.totalDeposit += amount;
        if(_nftCount < 88888 && isWin()) _nftCount = _nftContract.mint(msg.sender); // 抽奖
        return true;       
    }
    
    function getMyNftList() public view returns(uint256[] memory){
        uint256 len = _nftCount;
        uint256[] memory nftList = new uint256[](100); 
        uint256 i=1;
        for(;i<=len;i++){
            if(_nftContract.ownerOf(i) == msg.sender){
                nftList[i] = i;
            }
        }
        return nftList;
    }

    // 查询每张NFT卡收益
    function getPerNftReward() public view returns (uint256){
        if(_nftCount == 0) return 0;
        return _nftReward/_nftCount; 
    }

    function getNftRemainRewad(address nftOwner, uint256[] memory nftList) public view returns(uint256){
        uint256 perNftReward = getPerNftReward(); 
        uint256 totalReward = 0;
        for(uint i=0;i<nftList.length;i++){
            require(_nftContract.ownerOf(nftList[i]) == nftOwner, "ETE: nft's owner error");
            if(_tokenIdTotalClaim[nftList[i]] < perNftReward){ // 只计算那些可以领余额的卡
                totalReward += (perNftReward-_tokenIdTotalClaim[nftList[i]]);
            }
        }
        /* 出现这种情况是因为NFT变多了，变多之前每张NFT收益大于现在的，而且之前的卡的收益已经领取完了
          比如刚开始是10张卡分100U，每张能分10U，大家都领完了；然后现在变成20张卡，分100U，每张算出来
          只能分5U
        */ 
        return totalReward;
    }
    
    // 提现Nft卡收益
    function withdrawNftReward(uint256[] memory nftList) public returns (bool){
        uint256 perNftReward = getPerNftReward();
        uint256 reward = getNftRemainRewad(msg.sender, nftList);
        require(reward > 0, "ETE: insuffcient NFT reward amount");
        for(uint i=0;i<nftList.length;i++){
            if(_tokenIdTotalClaim[nftList[i]] < perNftReward){
                _tokenIdTotalClaim[nftList[i]] = perNftReward; // 更新这个nft领过总收益
            }
        }
        _usdtContract.transfer(msg.sender, reward);
        return true;
    }    
    
    function addContractBalance(uint256 amount) public {
        require(msg.sender == address(_ifoContract), "ETE: only IFO contract can call this function");
        _nftReward += amount;
        emit BalanceUpdate(amount);
    }

    function isWin() public view returns(bool){
        uint256 winningNum = uint256(keccak256(abi.encodePacked(
                    block.timestamp + 
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit + 
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) + 
                    block.number
                ))) % 9;
        return winningNum == 8;
    }

    constructor(address usdtContractAddress, address ifoContractAddress, 
        address nftContractAddress, address ifoHolder) {
        _usdtContract = IERC20(usdtContractAddress);
        _ifoContract = IERC20(ifoContractAddress);
        _nftContract = IERC721(nftContractAddress);
        _price = 25; // 0.0025U
        _ifoHolder = ifoHolder; // 用户用U购买IFO，从这个帐号买
        _buyAmountLimit = 1e20;
    }
}
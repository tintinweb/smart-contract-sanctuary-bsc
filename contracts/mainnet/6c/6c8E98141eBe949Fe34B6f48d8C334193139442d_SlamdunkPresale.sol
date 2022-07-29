/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    //   constructor () internal { }

    function _msgSender() internal view returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}


contract SlamdunkPresale is Ownable {
    address public _owner;
    
    mapping(address=>bool) public whiteList;
    mapping(address=>uint256) public presaleMap;
    mapping(address=>uint256) public presaleAmountMap;
    uint256 nowProgress = 0;
    uint256 maxProgress = 10000;
    uint256 price = 100 * 10**18;
    uint256 public canClaim;

    uint256 public  total; 

    address public tokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public claimToken = 0x1336Ec27bDaA61E59F73Db1cA1E3420f09Cf693e; 
    
    uint256 public amountPerIdo = 10000 * 10**18;


    constructor() {
        // 初始化router
        _owner = _msgSender();
        whiteList[_owner] = true;
    }

    

    function withdraw() external payable onlyOwner{
        payable(_owner).transfer(address(this).balance);
    }

    function withdrawToken() external payable onlyOwner {
        IERC20 t = IERC20(tokenAddress);
        t.transfer(_owner,t.balanceOf(address(this)));
    }

    function withdrawClaimToken() external payable onlyOwner {
        IERC20 t = IERC20(claimToken);
        t.transfer(_owner,t.balanceOf(address(this)));
    }

    function setClaimTokenAddress(address _a) public onlyOwner{
        claimToken = _a;
    }

    function setTokenAddress(address _addr) public onlyOwner{
        tokenAddress = _addr;
    }

    function setAmountPerIdo(uint256 _a) public {
        amountPerIdo = _a;
    }

    function setMultiWhiteList(address[] memory _a,bool _status ) public onlyOwner {
        for(uint256 i = 0;i<_a.length;i++){
            whiteList[_a[i]] = _status;
        }
    }

    function setNowProgress(uint256 _progress) public onlyOwner{
        nowProgress = _progress;
    }

    function setMaxProgress(uint256 _max) public onlyOwner{
        maxProgress = _max;
    }

    function getNowProgress() public view returns(uint256){
        return nowProgress;
    }


    function getMaxProgress() public view returns(uint256){
        return maxProgress;
    }

    function getPresaleStatus(address _a) public view returns( uint256 ){
        return presaleMap[_a];
    }

    function setPresaleStatus(address _a,uint256 _status) public onlyOwner{
         presaleMap[_a] = _status;
    }

    function setPrice(uint256 _price) public onlyOwner{
        price = _price;
    }


    function contribute() public payable{
        require(nowProgress+1 <= maxProgress, "max progress");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this),price);
        total+= price; 
        presaleMap[msg.sender]+=1;
        presaleAmountMap[msg.sender]+=price;
        nowProgress +=1;
    }

    function claimAmount(address _a) public view returns (uint256){
        return presaleMap[_a] * amountPerIdo;
    }

    function setClaimStatus(uint256 status) public onlyOwner {
        canClaim = status;
    }

    function claim() public {
        require(canClaim>0,"can not claim");
        uint256 _a = claimAmount(msg.sender);
        IERC20 t = IERC20(claimToken);
        require(t.balanceOf(address(this)) >= _a,"insufficient claim token balances");
        t.transfer(msg.sender,_a);
        presaleMap[msg.sender] = 0;
    }
}
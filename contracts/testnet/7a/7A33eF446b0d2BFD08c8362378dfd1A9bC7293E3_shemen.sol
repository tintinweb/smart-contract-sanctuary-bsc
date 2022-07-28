/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IInvitation {
    function getInvitation(address user) external view returns(address inviter, address[] memory invitees);
}

interface NftStake{
    function updateRewards() external;
}



contract shemen is Ownable{
    //address public bftAddr = 0xC4e83B0EF81B4C7CAb394f1C0D4A39bf8bc4e248;
    address public bftAddr =  0x07a6406AAa0A3a07404e3c66880776d8Ef49245C;
    address public feeAddr = 0x9Df4F0BA85F4a84085b88ed1aF972d10b3CF1790;
    //address  public invitationAddr = 0x449FF2Ac30d1106BE74A30E5A1538f724Bc42109;
    address  public invitationAddr = 0x6599a844454e434530547e6A9d7563d9811f14D7;
    
    address public nftAddr = 0x4d036C860Dd2b5DcE639dA60349086dDDe88e7b9;
    uint public minBet = 500e18;
    uint public maxBet = 10000e18;
    address public gasAddr = 0x8AaC9E5676Da8AbA3C893A679da85d9305102b70;
    uint public gas = 0.0013 ether;
    mapping(address=>bool) whiteAddrs;
    //seed
    uint nonce;
    bytes32 keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
    mapping(bytes32 => Result) request;
    bytes32[] private requestAry;
    address[] private requestAddrs;
    uint public reqIndex;
    
   // mapping(uint => Result) private result;
    struct Result {
        bool enable;
        uint betNum;
        address addr;
        uint amount;
    }
    mapping(address => bool) public supplier;
    address[] public suppliers;

    event ResultDataEvent(address indexed sender,uint betNum,uint randomNum,uint amount,uint income,address inviter,uint inviterIncome,uint timestamp);
    constructor()  {}

    function bet(uint amount,uint num) external payable{
        require(amount >= minBet,"too little");
        require(amount <= maxBet,"too much");
        require(num >= 1,"1~94");
        require(num <=94,"1~94");
        require(msg.value >= gas,"BNB too low");

        IERC20(bftAddr).transferFrom(msg.sender,address(this),amount);
       uint bnbBalance = address(this).balance;
       if (bnbBalance >=1e15){
           payable(gasAddr).transfer(bnbBalance);
       }
        
        
        //diaoyongsuijishu
        bytes32 reqId = makeReqId(msg.sender);
        request[reqId].enable = false;
        request[reqId].betNum = num;
        request[reqId].amount = amount;
        request[reqId].addr = msg.sender;
        requestAry.push(reqId);
        requestAddrs.push(msg.sender);
        //NftStake(nftAddr).updateRewards();

    }

    function betResult(bytes32 reqId, uint randomNum) internal{
        uint income;
        address inviter;
        uint inviterIncome;
        if (request[reqId].betNum >= randomNum){
            //win
            uint reward = request[reqId].amount * 100 / request[reqId].betNum;
            if (whiteAddrs[request[reqId].addr]) {
                IERC20(bftAddr).transfer(request[reqId].addr,reward);
            } else {
                (inviter,) = IInvitation(invitationAddr).getInvitation(request[reqId].addr);
                if (inviter ==address(0)){
                    IERC20(bftAddr).transfer(feeAddr,reward * 3 /100);
                } else {
                    IERC20(bftAddr).transfer(inviter,reward * 3 /100);
                    inviterIncome = reward * 3 /100;
                }
                //nft
                IERC20(bftAddr).transfer(nftAddr,reward * 2 /100);

                IERC20(bftAddr).transfer(request[reqId].addr,reward * 95 /100);
                income = reward * 95 /100 - request[reqId].amount;
            }
        } else {
            //lose
            if (!whiteAddrs[request[reqId].addr]) {
                uint reward = request[reqId].amount;
                (inviter,) = IInvitation(invitationAddr).getInvitation(request[reqId].addr);
                if (inviter ==address(0)){
                    IERC20(bftAddr).transfer(feeAddr,reward * 3 /100);
                } else {
                    IERC20(bftAddr).transfer(inviter,reward * 3 /100);
                    inviterIncome = reward * 3 /100;
                }
                //nft
                IERC20(bftAddr).transfer(nftAddr,reward * 2 /100);
                
            }
            income = 0;        
        }
        emit ResultDataEvent(request[reqId].addr,request[reqId].betNum,randomNum,request[reqId].amount,income,inviter,inviterIncome,block.timestamp);

    }
     function makeReqId(address addr) internal returns (bytes32) {
        nonce ++;
        uint seed = uint(keccak256(abi.encode(addr, address(this), nonce)));
        return keccak256(abi.encodePacked(keyHash, seed));
    }

    function responseFunc(bytes32[] calldata reqIds, uint[] calldata numbers) external {
        require(supplier[msg.sender] || supplier[tx.origin], "non access");
        require(reqIds.length == numbers.length, "length not match");

        bytes32 reqId;
        uint number;

        for (uint i=0; i<reqIds.length; i++){

            reqId = reqIds[i];
            number = numbers[i];
            if (!request[reqId].enable){
                betResult(reqId,number);
                request[reqId].enable = true;
                reqIndex ++;
            }
        }

    }

    function getReqAry() external view returns (bytes32[] memory reqIds,address[] memory reqAddrs){
        uint l = requestAry.length - reqIndex;
        if (l > 100) {
            l = 100;
        }
        reqIds = new bytes32[](l);
        reqAddrs = new address[](l);
        for (uint i=0; i<l; i++) {
            reqIds[i] = requestAry[i + reqIndex];
            reqAddrs[i] = requestAddrs[i + reqIndex];
        }
    }

    function setSupplier(address a, bool enable) public onlyOwner{
        if (enable) {
            suppliers.push(a);
        }
        supplier[a] = enable;
    }


    function setminBet(uint s) external onlyOwner {
        minBet = s;
    }

    function setmaxBet(uint s) external onlyOwner {
        maxBet = s;
    }
    function setwhiteAddrs(address addr,bool b) external onlyOwner {
        whiteAddrs[addr] = b;
    }
    function withdraw(address token, address recipient,uint amount) onlyOwner external {
        IERC20(token).transfer(recipient, amount);
    }

    function setNftAddr(address addr) external onlyOwner {
        nftAddr = addr;
    }
    function setInvitationAddr(address addr) external onlyOwner {
        invitationAddr = addr;
    }
    function setFeeAddr(address addr) external onlyOwner {
        feeAddr = addr;
    }
     function withdrawGas(uint gass) external onlyOwner {
        payable(gasAddr).transfer(gass);
    }
    function setGas(uint gass) external onlyOwner {
        gas = gass;
    }
    function setGasAddr(address addr) external onlyOwner {
        gasAddr = addr;
    }

    
}
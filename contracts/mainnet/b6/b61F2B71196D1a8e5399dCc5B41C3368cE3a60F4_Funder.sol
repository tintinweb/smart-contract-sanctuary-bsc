/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// File: lib/IFMT.sol


// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.8.6;

interface IFMT {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function fundAddr() external view returns (address);
    function getTokenManager()external view returns(address);
    function getMainPair()external view returns(address);
    function getUserTeamTotalAmount(address _user)external view returns(uint,uint[9] memory);
    function getUserTeamr(address _user,uint8 _layer,uint _begin,uint _end)external view returns(address[] memory _teamr);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function checkReleasedAmount(address _userAddr) external view returns (uint256);
    function safeRegisterUser(address _userAddress,address _inviter) external returns(bool);
    function includedUser(address) external returns (bool);
    function getInviter(address _userAddr)external view returns(address[9] memory);
    function fmtBurn(uint _amount)external;
    function addBuyAmount(address _user,uint _amount)external;
}
// File: lib/IERC20.sol


// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: lib/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: lib/Ownable.sol



pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

// File: contract/FMT-Funder.sol


pragma solidity ^0.8.6;




contract Funder is Ownable{
    IERC20 public USDT;
    IFMT public FMT;
    address[2] funder;
    bool initContract;

    constructor() {
        funder[0]=0xfB98a2dBB4a2b51CFdC2579E9796e8Caa2B4b076;
        funder[1]=0x6a872eb3aa37C0396Ccd7D3a06524e0A94AA3b3a;
    }
    function setContract(address _usdtAddr,address _fmtAddr)public onlyOwner{
        USDT=IERC20(_usdtAddr);
        FMT=IFMT(_fmtAddr);
        initContract=true;
    }

    function withdrawToken(address _tokenAddr,uint _amount)public onlyOwner{
        IERC20 _token=IERC20(_tokenAddr);
        require(_token.balanceOf(address(this))>=_amount);
        uint amount1 = _amount/100*75;
        uint amount2 = _amount-amount1;
        _token.transfer(funder[0], amount1);
        _token.transfer(funder[1], amount2);
    }
    
    function withdrawFMT(uint _amount)public onlyOwner{
        require(initContract,"Contract not initialized");
        require(FMT.balanceOf(address(this))>=_amount,"Insufficient Balance!");
        uint amount1 = _amount/100*75;
        uint amount2 = _amount-amount1;
        FMT.transfer(funder[0], amount1);
        FMT.transfer(funder[1], amount2);
    }
    
    function withdrawUSDT(uint _amount)public onlyOwner{
        require(initContract,"Contract not initialized");
        require(USDT.balanceOf(address(this))>=_amount,"Insufficient Balance!");
        uint amount1 = _amount/100*75;
        uint amount2 = _amount-amount1;
        USDT.transfer(funder[0], amount1);
        USDT.transfer(funder[1], amount2);
    }
}
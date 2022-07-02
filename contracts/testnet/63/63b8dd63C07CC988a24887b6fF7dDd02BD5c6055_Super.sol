/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity 0.5.16;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () internal {
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
     * @dev Returns the address of the current owner.
   */
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract Super is Ownable{
    address public _dol;//dollar
    address public _pay;//usdt
    address public _white;//白名单
    address public _bond;//bond
    address public _stake;//质押
    address public _vault;//金库
    address public _treasury;//国库
    address public _pool;//资金池
    address public _dao;//dao
    address public _vc;//vc
    address public _fomo3d;//fomo3d
    //设置各合约地址
    function setContract(address dol,
                        address pay,
                        address white,
                        address bond,
                        address stake,
                        address vault,
                        address treasury,
                        address pool,
                        address dao,
                        address vc,
                        address fomo3d) external onlyOwner {
        _dol = dol;
        _pay = pay;
        _white = white;
        _bond = bond;
        _stake = stake;
        _vault = vault;
        _treasury = treasury;
        _pool = pool;
        _dao = dao;
        _vc = vc;
        _fomo3d = fomo3d;
    }
}
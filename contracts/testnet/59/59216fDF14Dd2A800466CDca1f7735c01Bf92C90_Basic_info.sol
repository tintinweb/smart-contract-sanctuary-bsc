// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBasic_info.sol";

contract Basic_info is Ownable,IBasic_info {

    string[45] X = ["0","-180","-171.8181837","-163.6363674","-155.4545511","-147.2727348","-139.09091850000002","-130.9091022","-122.7272859","-114.5454696","-106.3636533","-98.18183700000002","-90.00002070000001","-81.8182044","-73.6363881","-65.45457180000001","-57.27275550000002","-49.09093920000001","-40.9091229","-32.72730659999999","-24.54549030000001","-16.36367400000003","-8.181857700000023","-0.00004140000001484623","8.181774899999994","16.363591200000002","24.545407499999982","32.72722379999999","40.9090401","49.09085639999998","57.27267269999999","65.45448899999997","73.63630529999998","81.81812159999998","89.99993789999996","98.1817542","106.36357049999998","114.54538680000002","122.7272031","130.90901939999998","139.09083569999996","147.27265199999994","155.45446829999997","163.63628459999995","171.8181009"];

    string[27] Y = ["0","85","78.46153859","71.92307718","65.38461577","58.84615436","52.30769295","45.76923154","39.23077013","32.69230872","26.153847309999996","19.615385900000007","13.076924489999996","6.53846308","0.0000016700000031732998","-6.538459739999993","-13.07692114999999","-19.61538256","-26.153843969999983","-32.69230538000001","-39.23076678999999","-45.769228199999986","-52.30768961000001","-58.84615102000001","-65.38461242999998","-71.92307384","-78.46153525"];


    function GetCoordinate (uint256 ID)  public virtual override view  returns  (string memory x,string memory y) {
      uint256 Num = ID/44;  
      uint256 _X;
      uint256 _Y;

      if(ID==44){
        _X = ID;
        _Y = 1;
      }
      else if (Num>1 && 44*Num==ID) {
        _X=44;
        _Y=Num;
      }
      else {
         _X = ID -Num*44;
         _Y= Num+1;
      }
        return (X[_X], Y[_Y]);
    }


    function withdraw(address payable adr) public payable onlyOwner{
    (bool hs, ) = payable(adr).call{value: address(this).balance}("");
    require(hs);
    }    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBasic_info { 
    function GetCoordinate (uint256 ID)  external view  returns  (string memory x,string memory y);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
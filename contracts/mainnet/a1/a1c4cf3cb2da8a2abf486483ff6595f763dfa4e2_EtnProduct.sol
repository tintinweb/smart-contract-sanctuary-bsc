/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

pragma solidity 0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IEtnProd{
    struct Product {
        uint price;
        string name;
        string video;
        string logo;
        string qrCode;
        string phone;
        string next;
        uint commId;
        uint shopId;
    }

    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function nftIdTokenMap(uint tokenId) external view returns (address erc20Addr);
    function tokenProdMap(address erc20Addr) external view returns (Product memory p );
}


contract EtnProduct is Ownable {
    IEtnProd public etnProd;

    constructor(address _etnProd) {
        etnProd = IEtnProd(_etnProd);
    }

    function getUserProducts(address to) public view returns (address[] memory , string[] memory,string[] memory,uint[] memory){
        uint len = etnProd.balanceOf(to);
        address[] memory erc20Addrs= new address[](len);
        string[] memory names = new string[](len);
        string[] memory logos = new string[](len);
        uint[] memory prices = new uint[](len);

        for (uint i = 0; i < len; i++) {
            uint tokenId = etnProd.tokenOfOwnerByIndex(to,i);
            address erc20Addr = etnProd.nftIdTokenMap(tokenId);
            IEtnProd.Product memory p = etnProd.tokenProdMap(erc20Addr);
            erc20Addrs[i] = erc20Addr;
            names[i] = p.name;
            logos[i] = p.logo;
            prices[i] = p.price;
        }
        return (erc20Addrs,names,logos,prices);
    }

    function setAddresses(address _etnProd) public onlyOwner {
        etnProd = IEtnProd(_etnProd);
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

/**
██╗░░██╗░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗░░█████╗░██████╗░███████╗
██║░░██║██╔══██╗██║░░░░░██╔══██╗██╔════╝░██╔══██╗██╔══██╗██╔══██╗██╔════╝
███████║██║░░██║██║░░░░░██║░░██║██║░░██╗░██████╔╝███████║██████╔╝█████╗░░
██╔══██║██║░░██║██║░░░░░██║░░██║██║░░╚██╗██╔══██╗██╔══██║██╔═══╝░██╔══╝░░
██║░░██║╚█████╔╝███████╗╚█████╔╝╚██████╔╝██║░░██║██║░░██║██║░░░░░███████╗
╚═╝░░╚═╝░╚════╝░╚══════╝░╚════╝░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚══════╝ 

*Контракт управления экосистемой Hologrape-NFT  2023 

*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHoloBasic.sol";
import "./IBEP20.sol";

contract HoloBasic is Ownable,IHoloBasic {

    event TransferSent(address _from, address _to, uint _amount);

     //адрес HolograpePlus
    address payable HoloPlus;
     //адрес HolograpeSeed
    address payable HoloSeed;

    //G,V,D,I процент 
    uint256[4] Procent_HoloPlus = [35,35,20,10];
    uint256[4] Procent_HoloSeed = [12,12,71,5];

    address G;
    address V;
    address D;
    address I;
    
    //цена holoplus
    uint PriceHoloPlus = 29;
    

     //Список поддерживаемых стейблкоинов
    mapping(address => bool) public allowedTokens;
        //Список decimals в стейблкоинах
    mapping(address => uint) public decimalsallowedTokens;

    constructor(address _G,address _V,address _D,address _I) {
        G=address(_G);
        V=address(_V);
        D=address(_D);
        I=address(_I);
    }

    //Распределение с покупки HoloPlus
    function distributionPlus(address _token,uint _amount, address adr) public virtual override {
        True_Token(_token,_amount,adr);
        IBEP20 BEP;
        BEP = IBEP20 (address(_token));
        
        uint256 OneP = _amount/100;
        
        BEP.transferFrom(adr, G, OneP*Procent_HoloPlus[0]);
        emit TransferSent(adr,G,Procent_HoloPlus[0]);

        BEP.transferFrom(adr, V, OneP*Procent_HoloPlus[1]);
        emit TransferSent(adr,V,Procent_HoloPlus[1]);

        BEP.transferFrom(adr, D, OneP*Procent_HoloPlus[2]);
        emit TransferSent(adr,D,Procent_HoloPlus[2]);

        BEP.transferFrom(adr, I, OneP*Procent_HoloPlus[3]);
        emit TransferSent(adr,I,Procent_HoloPlus[3]);
    }

    function distributionSeed(address _token,uint _amount, address adr) public virtual override {
        True_Token(_token,_amount,adr);

        IBEP20 BEP;
        BEP = IBEP20 (address(_token));
        
        uint256 OneP = _amount/100;
        
        BEP.transferFrom(adr, G, OneP*Procent_HoloSeed[0]);
        emit TransferSent(adr,G,Procent_HoloSeed[0]);

        BEP.transferFrom(adr, V, OneP*Procent_HoloSeed[1]);
        emit TransferSent(adr,V,Procent_HoloSeed[1]);

        BEP.transferFrom(adr, D, OneP*Procent_HoloSeed[2]);
        emit TransferSent(adr,D,Procent_HoloSeed[2]);

        BEP.transferFrom(adr, I, OneP*Procent_HoloSeed[3]);
        emit TransferSent(adr,I,Procent_HoloSeed[3]);
    }

    function True_Token (address _token, uint _amount,address adr) public virtual override {
        require(allowedTokens[_token] == true, "Token is not allowed/supported");
        IBEP20 BEP;
        BEP = IBEP20 (address(_token));
        require(BEP.balanceOf(adr) >= _amount, "Insufficient funds in the account");
    }

    function Donat(address _token, uint _amount,address adr) public {
        True_Token(_token,_amount,adr);

        bool success = IBEP20(_token).transferFrom(adr, D, _amount);
        emit TransferSent(adr, D,_amount);

        require(success, "Transaction was not successful");
    }

    function set_I(address new_adr) public {
        require(msg.sender==I);
        I=new_adr;    
    }

    //Получение цены 
    function getPriceHoloPlus() public virtual override view returns (uint) {
        return PriceHoloPlus;
    }
    //Изменение цены HoloPlus
    function setPriceHoloPlus(uint newPriceHoloPlus) public onlyOwner{
        PriceHoloPlus=newPriceHoloPlus;
    }

    function set_G (address newAddress) public onlyOwner {
        G=newAddress;
    }
    function set_V (address newAddress) public onlyOwner {
        V=newAddress;
    }

    function get_G () public virtual override view returns (address) {
        return G;
    }
    function get_V () public virtual override view returns (address) {
        return V;
    }
    function get_D () public virtual override view returns (address) {
        return D;
    }
    function get_I () public virtual override view returns (address) {
        return I;
    }

        //Добавление стейблкоинов 
    function allowAddress(address _token, uint decimals) public onlyOwner {
        allowedTokens[_token] = true;
        decimalsallowedTokens[_token] = decimals;
    }

      //Удаление стейблкоинов 
    function DeliteAddress(address _token) public onlyOwner {
        allowedTokens[_token] = false;
        decimalsallowedTokens[_token] = 0;
    }

        //Получение информации о возможности приема стейблкоина
    function getallowedTokens (address _token) public virtual override view returns (bool) {
        return allowedTokens[_token];
    }
        //Получение decimals в стейблкоинах
    function getdecimalsallowedTokens (address _token) public virtual override view returns (uint) {
        return decimalsallowedTokens[_token];
    }

    function getHoloPlus () public virtual override view returns (address) {
        return HoloPlus;
    }

    function getHoloSeed () public virtual override view returns (address) {
        return HoloSeed;
    }

        //Добавление адреса HolograpePlus
    function AddHolograpePlus(address payable _HoloPlus) external onlyOwner {
        HoloPlus=_HoloPlus;
    } 
        //Добавление адреса HolograpeSeed
    function AddHolograpeSeed(address payable _HoloSeed) external onlyOwner {
        HoloSeed=_HoloSeed;
    } 

    function withdraw() public payable onlyOwner{
    (bool hs, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(hs);
    }

    function withdrawToken(address _token,uint _amount) public payable onlyOwner{
        IBEP20 BEP;
        BEP = IBEP20 (address(_token));
    bool success = BEP.transferFrom(address(this),msg.sender, _amount);
    require(success, "Transaction was not successful");
}

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;
interface IHoloBasic {
    function getallowedTokens (address _token) external view returns (bool);
    function getdecimalsallowedTokens (address _token) external view returns (uint);
    function getPriceHoloPlus() external view returns (uint);
    function distributionPlus(address _token,uint summ, address adr) external;
    function distributionSeed(address _token,uint _amount, address adr) external;
    function True_Token (address _token, uint _amount,address adr) external;
    function getHoloPlus () external view returns (address);
    function getHoloSeed () external view returns (address);
    function get_G () external view returns (address);
    function get_V () external view returns (address);
    function get_D () external view returns (address);
    function get_I () external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
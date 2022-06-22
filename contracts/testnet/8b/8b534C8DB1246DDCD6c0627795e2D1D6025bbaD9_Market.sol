/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// File: @openzeppelin/contracts/utils/Counters.sol
// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: contracts/Market.sol


pragma solidity ^0.8.14;


// Importa String

// Importa Owner

// Importa SafeMath

// Counter


interface MarketNFT {
        function safeTransferFrom(
            address from,
            address to,
            uint256 id,
            uint256 amount,
            bytes calldata data
        ) external;
}



// Simples Interface do Contrato do Token

interface IBEP20 {
        function totalSupply() external view returns (uint);
        function allowance(address owner, address spender) external view  returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool) ;
        function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
        function balanceOf(address account) external view  returns (uint256);
        function approve(address _spender, uint256 _amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);  
        }

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
           
            if (returndata.length > 0) {
               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Market is Ownable {

    using Counters for Counters.Counter;
    using Address for address;

    
    // Endereço do Token
    IBEP20 public token;
    // Endereço BUSD
    IBEP20 public busd;
    //  Endereço de Marketing
    address public wallet;
    // Endereço do MarketPlace
    Market public market;
    constructor(IBEP20 _token, IBEP20 _busd, address _wallet )
    {
      token = _token;
      busd = _busd;
      wallet = _wallet;
    }



    /*
    * @ Atenção a partir da versão 0.8.0 Solidity não é mais preciso utilizar SafeMath ou Math
    * Mas por medidas de precaução recomendo manter o uso do SafeMath
    */
    using SafeMath for uint256;

    uint256 public taxFee = 10;

    // Cria um Novo ID
    Counters.Counter private tokenID;
    
    // Lista Endereços de NFT
    mapping(address => MarketList) public listing;
    // Mapeamento para Controle do Market
    mapping(uint256 => MarketItem) public marketItem;

    struct MarketList {
        uint256 isCounter;
        bool isList;
    }

    struct MarketItem {
        // ID do Contrato Market 
        uint256 idMarket;
        // ID do Contrato NFT
        uint256 idNFT;
        // Comprador da NFT
        address payable ownerNFT;
        // Vendedor da NFT
        address payable sellerNFT;
        // Preço em BUSD
        uint256 priceBUSD;
        // Preço em BNB
        uint256 priceBNB;
        // Preço em RHT
        uint256 priceRHT;
        // Booleano para Definir Compra e Venda
        bool sold;
    }


    // Adiciona um Endereço ao Market
    function addMarketList(address requester) external onlyOwner {
        MarketList storage list = listing[requester];
        list.isList = true;
    }
    // Remove um Endereço do Market
    function removeMarketList(address requester) external onlyOwner {
        MarketList storage list = listing[requester];
        list.isList = false;
        list.isCounter = 0;
    }
    // Ajusta a Taxa
    function setFee(uint256 _taxFee) external onlyOwner {
        taxFee = _taxFee;
    }

    function saleOrderBUSD(address isAddress, uint256 id, uint256 amount) external {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        // Cria um ID
        list.isCounter += 1;
        // Nova ID
        uint256 newID = list.isCounter;
        // Market Item
        MarketItem storage create = marketItem[newID];
        // Gera ID Market
        create.idMarket = newID;
        // Pega ID NFT
        create.idNFT = id;
        // Define o Market como Dono da NFT
        create.ownerNFT = payable(address(this));
        // Define msg.sender como seller (para poder cancelar a venda)
        create.sellerNFT = payable(_msgSender());
        //  Define o preço em BUSD
        create.priceBUSD = amount;
        // Define como True para Venda
        create.sold = true;
        // Transfere NFT
        MarketNFT(isAddress).safeTransferFrom(_msgSender(), address(this), id, 1, "" );
    }

    function saleOrderRHT(address isAddress, uint256 id, uint256 amount) external {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        // Cria um ID
        list.isCounter += 1;
        // Nova ID
        uint256 newID = list.isCounter;
        // Market Item
        MarketItem storage create = marketItem[newID];
        // Gera ID Market
        create.idMarket = newID;
        // Pega ID NFT
        create.idNFT = id;
        // Define o Market como Dono da NFT
        create.ownerNFT = payable(address(this));
        // Define msg.sender como seller (para poder cancelar a venda)
        create.sellerNFT = payable(_msgSender());
        //  Define o preço em BUSD
        create.priceRHT = amount;
        // Define como True para Venda
        create.sold = true;
        // Transfere NFT
        MarketNFT(isAddress).safeTransferFrom(_msgSender(), address(this), id, 1, "" );
    }

    function saleOrderBNB(address isAddress, uint256 id, uint256 amount) external {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        // Cria um ID
        list.isCounter += 1;
        // Nova ID
        uint256 newID = list.isCounter;
        // Market Item
        MarketItem storage create = marketItem[newID];
        // Gera ID Market
        create.idMarket = newID;
        // Pega ID NFT
        create.idNFT = id;
        // Define o Market como Dono da NFT
        create.ownerNFT = payable(address(this));
        // Define msg.sender como seller (para poder cancelar a venda)
        create.sellerNFT = payable(_msgSender());
        //  Define o preço em BUSD
        create.priceBNB = amount;
        // Define como True para Venda
        create.sold = true;
        // Transfere NFT
        MarketNFT(isAddress).safeTransferFrom(_msgSender(), address(this), id, 1, "" );
    }

    function stopOrder(address isAddress, uint256 id) external {
        // Market Item
        MarketItem storage create = marketItem[id];
        require(create.sold, "This NFT is not for sale!");
        require(create.sellerNFT == _msgSender(), "You do not own this NFT!");
        // Define o Market como Dono da NFT
        create.ownerNFT = payable(_msgSender());
        // Define msg.sender como seller (para poder cancelar a venda)
        create.sellerNFT = payable(address(0));
        //  Define o preço em BUSD
        create.priceBUSD = 0;
        //  Define o preço em BNB
        create.priceBNB = 0;
        //  Define o preço em RHT
        create.priceRHT = 0;
        // Transfere NFT de volta para o Vendedor (Cancelou a Venda)
        MarketNFT(isAddress).safeTransferFrom(address(this), _msgSender(), id, 1, "" );
    }

    function buyOrder(address isAddress, uint256 id) external payable {
        // Market Item
        MarketItem storage create = marketItem[id];
        require(create.sold, "This NFT is not for sale!");
        //  Verifica em qual forma de Pagamento foi Definido a Venda
        if(create.priceBUSD > 0) {
            // Pega o Montante Total
            uint256 amountBUSD = create.priceBUSD;
            IBEP20(busd).transferFrom(_msgSender(), address(this), amountBUSD);
            // Faz a divisao de Taxa
            uint256 rateCalculation = amountBUSD.mul(taxFee).div(100);
            uint256 resultFee = amountBUSD.sub(rateCalculation);
            IBEP20(busd).transfer(create.sellerNFT,resultFee);
            // Transfere as Taxas para o Owner do Contrato
            IBEP20(busd).transfer(wallet, rateCalculation);
            // Bloqueio de Reentradas
            amountBUSD = 0;
            rateCalculation = 0;
            resultFee = 0;
            //  Define o preço em BUSD
            create.priceBUSD = 0;
        }
        require(create.priceBUSD > 0 || create.priceBNB > 0 || create.priceRHT > 0, "No payment method is defined");
        if(create.priceBNB > 0) {
            uint256 price = create.priceBNB;
            uint256 rateCalculation = price.mul(taxFee).div(100);
            uint256 result = price.sub(rateCalculation);
            require(msg.value == price, "BNB: Must be identical to the price set by the Seller");
            // Transfere BNB para o Vendedor
            payable(create.sellerNFT).transfer(result);
            // Transfere BNB para o Owner
            payable(wallet).transfer(rateCalculation);
            // Bloqueio de Reentradas
            price = 0;
            rateCalculation = 0;
            result = 0;
            //  Define o preço em BNB
            create.priceBNB = 0;
        }
        if(create.priceRHT > 0) {
            // Pega o Montante Total
            uint256 amountRHT = create.priceRHT;
            IBEP20(token).transferFrom(_msgSender(), address(this), amountRHT);
            // Faz a divisao de Taxa
            uint256 rateCalculation = amountRHT.mul(taxFee).div(100);
            uint256 resultFee = amountRHT.sub(rateCalculation);
            IBEP20(token).transfer(create.sellerNFT,resultFee);
            // Transfere as Taxas para o Owner do Contrato
            IBEP20(token).transfer(wallet, rateCalculation);
            // Bloqueio de Reentradas
            amountRHT = 0;
            rateCalculation = 0;
            resultFee = 0;
            //  Define o preço em RHT
            create.priceRHT = 0;
        }
        
        // Define o Market como Dono da NFT
        create.ownerNFT = payable(_msgSender());
        // Define msg.sender como seller (para poder cancelar a venda)
        create.sellerNFT = payable(address(0));
        // Transfere NFT de volta para o Vendedor (Cancelou a Venda)
        MarketNFT(isAddress).safeTransferFrom(address(this), _msgSender(), id, 1, "" );
    }


    function fetchMarketItems(address isAddress) public view returns(MarketItem[] memory) {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        uint256 totalItemCount = list.isCounter;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketItem[i + 1].ownerNFT == address(this)) {
            itemCount += 1;
        }}

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketItem[i + 1].ownerNFT == address(this)) {
            uint256 currentId = i + 1;
            MarketItem storage currentItem = marketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMySeller(address isAddress) public view returns(MarketItem[] memory) {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        uint256 totalItemCount = list.isCounter;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
        if (marketItem[i + 1].sellerNFT == _msgSender()) {
            itemCount += 1;
        }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
        if (marketItem[i + 1].sellerNFT == _msgSender()) {
            uint256 currentId = i + 1;
            MarketItem storage currentItem = marketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        }
        return items;
    }

    function fetchMyItems(address isAddress) public view returns(MarketItem[] memory) {
        MarketList storage list = listing[isAddress];
        require(list.isList, "This collection is not listed on the Market!");
        uint256 totalItemCount = list.isCounter;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketItem[i + 1].ownerNFT == _msgSender()) {
            itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketItem[i + 1].ownerNFT == _msgSender()) {
            uint256 currentId = i + 1;
            MarketItem storage currentItem = marketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
            }
        }
        return items;
    }


    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

}
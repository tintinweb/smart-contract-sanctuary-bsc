pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUnilab.sol";
import "./libraries/structs.sol";

contract Bookkeeper is Ownable, IBookkeeper {
    event ContractCreated(address indexed addr);
    event PaymentGatewayStatus(address indexed addr, bool status);

    // contracts
    address[] public allContracts;
    mapping(address => Structs.ContractInfo) public contractInfo;
    mapping(address => Structs.ContractInfo[]) public contractsByCreator;

    // templates
    Structs.TemplateInfo[] public allTemplates;
    mapping(uint256 => Structs.TemplateInfo) public templateInfo;
    mapping(bytes32 => Structs.TemplateInfo) public templateInfoByCodehash;

    // payment gateways
    mapping(address => bool) public paymentGateways;

    bool public performChecks = true;

    modifier isValidPG() {
        require(paymentGateways[msg.sender], "BK: invalid payment gateway");
        _;
    }

    function getNumberOfContractsDeployed() external view returns (uint256) {
        return allContracts.length;
    }

    function getNumberOfTemplatesSupported() external view returns (uint256) {
        return allTemplates.length;
    }

    function getAllTemplates() external override view returns (Structs.TemplateInfo[] memory) {
        return allTemplates;
    }

    function getAllContracts(bool onlyVerified) external view returns (address[] memory) {
        if (!onlyVerified) {
            return allContracts;
        }

        address[] memory result = new address[](_getCount(allContracts));
        for (uint256 i = 0; i < allContracts.length; i++) {
            address c = allContracts[i];
            if (isContractVerified(c)) {
                result[i] = c;
            }
        }

        return result;
    }

    function getAllContractsByIndex(uint i, uint j, bool onlyVerified) external view returns (address[] memory) {
        uint idx = 0;
        if (!onlyVerified) {
            address[] memory result = new address[](j - i);

            for (uint k = i; k < j; k++) {
                result[idx] = allContracts[k];
                idx += 1;
            }

            return result;
        } else {
            idx = 0;
            address[] memory contracts = new address[](j - i);
            for (uint k = i; k < j; k++) {
                contracts[i] = allContracts[k];
                idx += 1;
            }

            address[] memory result = new address[](_getCount(contracts));
            idx = 0;
            for (uint256 m = 0; m < contracts.length; i++) {
                address c = contracts[m];
                if (isContractVerified(c)) {
                    result[idx++] = c;
                }
            }

            return result;
        }
    }

    function getContractsInfo(address[] memory addrs, bool onlyVerified) external view returns (Structs.ContractInfo[] memory) {
        if (!onlyVerified) {
            Structs.ContractInfo[] memory infos = new Structs.ContractInfo[](addrs.length);

            for (uint i = 0; i < infos.length; i++) {
                infos[i] = contractInfo[addrs[i]];
            }

            return infos;
        } else {
            Structs.ContractInfo[] memory result = new Structs.ContractInfo[](_getCount(addrs));
            uint idx = 0;
            for (uint256 i = 0; i < addrs.length; i++) {
                address c = addrs[i];
                if (isContractVerified(c)) {
                    result[idx++] = contractInfo[c];
                }
            }

            return result;
        }
    }


    function getAllContractsByCreator(address creator, bool onlyVerified) public view returns (Structs.ContractInfo[] memory) {
        if (!onlyVerified) return contractsByCreator[creator];

        Structs.ContractInfo[] memory result = new Structs.ContractInfo[](_getCount(contractsByCreator[creator]));
        uint idx = 0;
        for (uint256 i = 0; i < contractsByCreator[creator].length; i++) {
            address c = contractsByCreator[creator][i].contractAddress;
            if (isContractVerified(c)) {
                result[idx++] = contractInfo[c];
            }
        }

        return result;
    }

    function getNumberOfContractsCreatedByUser(address creator, bool onlyVerified) external view returns (uint256) {
        Structs.ContractInfo[] memory contracts = getAllContractsByCreator(creator, onlyVerified);

        return contracts.length;
    }

    function isContractVerified(address a) public view returns (bool) {
        // get code hash
        bytes32 hash = a.codehash;
        // make sure code is a registered template
        return templateInfoByCodehash[hash].codehash == hash;
    }

    function register(address addr, uint256 id) external override payable isValidPG {
        // only newly created contracts should call registerContract
        if (performChecks) {
            uint32 size;
            assembly {
                size := extcodesize(addr)
            }
            require(tx.origin != msg.sender, "BK: Must be called by a contract");
            require(size == 0, "BK: Invalid contract state");
        }

        _registerContract(addr, tx.origin, block.timestamp, id);
    }

    function _registerContract(address addr, address creator, uint256 timestamp, uint256 id) internal {
        Structs.ContractInfo storage info = contractInfo[addr];

        info.timestamp = timestamp;
        info.creator = creator;
        info.templateId = id;
        info.contractAddress = addr;

        contractsByCreator[creator].push(info);
        allContracts.push(addr);

        emit ContractCreated(addr);
    }

    function registerTemplate(uint256 id,
        bytes32 codehash,
        string memory name,
        bytes32 version,
        uint256 price,
        address paymentToken) external onlyOwner {
        Structs.TemplateInfo storage info = templateInfo[id];
        info.id = id;
        info.codehash = codehash;
        info.name = name;
        info.version = version;
        info.price = price;
        info.paymentToken = paymentToken;
        info._index = allTemplates.length;

        templateInfoByCodehash[codehash] = info;
        allTemplates.push(info);
    }

    function deregisterTemplate(uint256 id) external onlyOwner {
        Structs.TemplateInfo memory info = templateInfo[id];

        delete templateInfo[id];
        delete templateInfoByCodehash[info.codehash];

        if (allTemplates.length > 1) {
            Structs.TemplateInfo storage lastTemplate = allTemplates[allTemplates.length - 1];
            allTemplates[info._index] = lastTemplate;
            lastTemplate._index = info._index;
        }

        allTemplates.pop();
    }

    function setTemplatePrice(uint256 id, uint256 price, address paymentToken) external onlyOwner {
        Structs.TemplateInfo storage info = templateInfo[id];
        require(info.id == id, "template does not exist");

        info.price = price;
        info.paymentToken = paymentToken;
    }

    function setPerformChecks(bool value) external onlyOwner {
        performChecks = value;
    }

    function setPaymentGatewayStatus(address pg, bool approved) external onlyOwner {
        paymentGateways[pg] = approved;

        emit PaymentGatewayStatus(pg, approved);
    }

    function registerContractManually(address cont, address creator, uint256 timestamp, uint256 id) external onlyOwner {
        _registerContract(cont, creator, timestamp, id);
    }

    function registerContractsManually(address[] memory contracts, address[] memory creators, uint256[] memory timestamps, uint256 [] memory id) external onlyOwner {
        for (uint i = 0; i < contracts.length; i++) {
            _registerContract(contracts[i], creators[i], timestamps[i], id[i]);
        }
    }

    function getTemplatePrice(uint256 id) external override view returns (uint256, address) {
        Structs.TemplateInfo storage info = templateInfo[id];

        require(info.id == id, "BK: invalid id");

        return (info.price, info.paymentToken);
    }

    function getTemplatePriceByCodehash(bytes32 codehash) external override view returns (uint256, address) {
        Structs.TemplateInfo storage info = templateInfoByCodehash[codehash];

        require(info.codehash == codehash, "BK: invalid codehash");

        return (info.price, info.paymentToken);
    }

    function _getCount(address[] memory contracts) internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < contracts.length; i++) {
            if (isContractVerified(contracts[i])) {
                count += 1;
            }
        }

        return count;
    }

    // overload
    function _getCount(Structs.ContractInfo[] memory contracts) internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < contracts.length; i++) {
            if (isContractVerified(contracts[i].contractAddress)) {
                count += 1;
            }
        }

        return count;
    }

    function withdraw(address token) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }
}

contract PaymentGateway is Ownable, IRegistrar {
    bytes32 constant version = "0.0.1";
    IBookkeeper public bk;
    address public tokenToHold;
    uint256 public minimumHolding;

    struct DiscountInfo {
        // value between 0-100 which reflect the discount the user has on the base price.
        uint256 discountPercentage;
        // count - how many contracts the user can create
        uint256 count;
    }

    mapping(address => DiscountInfo) public discountPerUser;
    uint256 public globalDiscount = 0;

    constructor(address _bk) {
        bk = IBookkeeper(_bk);
    }

    function register(address addr, uint256 id) external payable override {
        if (tokenToHold != address(0) && minimumHolding > 0) {
            require(IERC20(tokenToHold).balanceOf(tx.origin) >= minimumHolding, "PG: not enough token balance");
        }

        (uint256 price, address token) = getPrice(tx.origin, id);

        if (token == address(0)) {
            require(msg.value >= price, "PG: invalid amount");
            payable(owner()).transfer(msg.value);
        } else {
            require(IERC20(token).transferFrom(tx.origin, owner(), price), "PG: transfer failed");
        }

        useDiscount(tx.origin);
        bk.register(addr, id);
    }

    function updateBookkeeper(address newRegistrar) external onlyOwner {
        bk = IBookkeeper(newRegistrar);
    }

    function getPrice(address who, uint256 id) public view returns (uint256, address) {
        (uint256 price, address token) = bk.getTemplatePrice(id);
        return (getPriceAfterDiscount(who, price), token);
    }

    function getPriceByCodehash(address who, bytes32 codehash) public view returns (uint256, address) {
        (uint256 price, address token) = bk.getTemplatePriceByCodehash(codehash);
        return (getPriceAfterDiscount(who, price), token);
    }

    function getPriceAfterDiscount(address who, uint256 price) public view returns (uint256) {
        uint256 discount = globalDiscount;
        if (discountPerUser[who].count > 0) {
            discount += discountPerUser[who].discountPercentage;
            if (discount > 100) {
                discount = 100;
            }
        }
        return (100 - discount) * price / 100;
    }

    function useDiscount(address who) internal {
        if (discountPerUser[who].count > 0) {
            discountPerUser[who].count -= 1;
        }
    }

    function setDiscount(address who, uint256 count, uint256 pct) external onlyOwner {
        require(pct <= 100, "invalid percent");

        discountPerUser[who] = DiscountInfo(pct, count);
    }

    function setGlobalDiscount(uint256 pct) external onlyOwner {
        require(pct <= 100, "invalid percent");

        globalDiscount = pct;
    }

    function setTokenToHold(address token) external onlyOwner {
        tokenToHold = token;
    }

    function setMinimumHolding(uint256 holding) external onlyOwner {
        minimumHolding = holding;
    }

    function getAllPrices(address who) external view returns (Structs.TemplateInfo[] memory) {
        Structs.TemplateInfo[] memory templates = bk.getAllTemplates();

        // Go over templates to check if there are available discounts
        for (uint i = 0; i < templates.length; i++) {
            (uint256 price, address token) = getPrice(who, templates[i].id);
            templates[i].price = price;
        }

        return templates;
    }

    function withdraw(address token) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IRegistrar {
    function register(address addr, uint256 id) external payable;
}

interface IBookkeeper is IRegistrar {
    function getTemplatePrice(uint256 id) external view returns(uint256, address);
    function getAllTemplates() external view returns(Structs.TemplateInfo[] memory);
    function getTemplatePriceByCodehash(bytes32 codehash) external view returns (uint256, address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Structs {
    struct FeeInfo {
        address beneficiary;
        uint256 fee;
    }

    struct ContractInfo {
        address creator;
        uint256 templateId;
        address contractAddress;
        uint256 timestamp;  // creation timestamp
    }

    struct TemplateInfo {
        uint256 id;
        bytes32 codehash;
        string name;
        bytes32 version;
        uint256 price;
        address paymentToken;

        uint _index; // Index in the array of templates
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
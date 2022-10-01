// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IXtatuzFactory.sol";
import "../interfaces/IXtatuzProject.sol";
import "../interfaces/IPresaled.sol";
import "../interfaces/IProperty.sol";
import "../interfaces/IXtatuzPricing.sol";
import "../interfaces/IXtatuzReroll.sol";

contract XtatuzRouter {
    using Counters for Counters.Counter;
    Counters.Counter private _projectIdCounter;

    IXtatuzFactory private _xtatuzFactory;

    address private _spvAddress;
    address private _xtatuzFactoryAddress;
    address private _membershipAddress;
    address public xtaTokenAddress;
    address private _pricingAddress;
    address private _rerollAddress;

    uint256 public triggerPeriod = 52 weeks;

    enum CollectionType {
        PRESALE,
        INCOMPLETE,
        COMPLETE
    }

    struct Collection {
        address contractAddress;
        uint256[] tokenIdList;
        CollectionType collectionType;
    }

    mapping(address => uint256[]) private _memberdProject;
    mapping(string => mapping(uint256 => uint256)) public referralPerProject; 
    mapping(address => mapping(uint256 => bool)) private _isMemberClaimed;
    mapping(address => mapping(uint256 => uint256)) private _triggerTimestamp;
    mapping(uint256 => uint256) private _totalRerollFee;

    constructor(
        address spv_,
        address factoryAddress_,
        address xtaTokenAddress_
    ) {
        _transferSpv(spv_);
        _xtatuzFactory = IXtatuzFactory(factoryAddress_);
        xtaTokenAddress = xtaTokenAddress_;
        _projectIdCounter.increment();
    }

    event SpvTransferred(address indexed prevSpv, address indexed newSpv);
    event CreatedProject(uint256 indexed projectId, address indexed projectAddress);
    event AddProjectMember(uint256 indexed projectId, address indexed member, string indexed referral, uint256 totalPrice);
    event Claimed(uint256 indexed projectId, address member);
    event Refunded(uint256 indexed projectId, address member);
    event Trigger(uint256 indexed projectId, address member, uint256 timestamp);
    event Buyback(uint256 indexed projectId, address member);
    event ChangePropertyStatus(uint256 indexed projectId, IProperty.PropertyStatus status);
    event NFTReroll(address indexed member, uint256 projectId, uint256 tokenId);
    event ClaimedRerollFee(address indexed spv, uint256 projectId, uint256 amount);

    modifier onlySpv() {
        require(_spvAddress == msg.sender, "ROUTER: ONLY_SPV");
        _;
    }

    modifier prohibitZeroAddress(address caller) {
        require(caller != address(0), "ROUTER: ADDRESS_0");
        _;
    }

    function createProject(
        uint256 count_,
        address tokenAddress_,
        string memory name_,
        string memory symbol_,
        uint256 startPresale_,
        uint256 endPresale_,
        IProperty.PackageDetail[] memory packages_
    ) public onlySpv {
        uint256 projectId = _projectIdCounter.current();
        require(startPresale_ >= block.timestamp - 1000, "ROUTER: INVALID_START_DATE");
        require(endPresale_ > startPresale_, "ROUTER: INVALID_END_DATE");

        uint256 totalSupply = IERC20(tokenAddress_).totalSupply();
        require(totalSupply > 0, "ROUTER: INVALID_TOKEN");

        _projectIdCounter.increment();
        IXtatuzFactory.ProjectPrepareData memory data = IXtatuzFactory.ProjectPrepareData({
            projectId_: projectId,
            spv_: msg.sender,
            trustee_: msg.sender,
            count_: count_,
            tokenAddress_: tokenAddress_,
            membershipAddress_: _membershipAddress,
            name_: name_,
            symbol_: symbol_,
            packages_: packages_,
            routerAddress: address(this)
        });

        address projectAddress = _xtatuzFactory.createProjectContract(data);
        IXtatuzProject(projectAddress).setPresalePeriod(startPresale_, endPresale_);
        emit CreatedProject(projectId, projectAddress);
    }

    function addProjectMember(
        uint256 projectId_,
        uint256 package_,
        uint256 amount_,
        string memory referral_
    ) public {
        address projectAddress = _xtatuzFactory.getProjectAddress(projectId_);
        IXtatuzProject project = IXtatuzProject(projectAddress);
        uint256 price = project.addProjectMember(msg.sender, package_, amount_);

        uint256 minPrice = project.minPrice();
        uint256 refAmount = (price - (amount_ * minPrice));
        referralPerProject[referral_][projectId_] += refAmount;

        address tokenAddress = project.tokenAddress();
        IERC20(tokenAddress).transferFrom(msg.sender, projectAddress, price);

        uint256[] memory memberedProject = _memberdProject[msg.sender];
        bool foundedIndex;
        for (uint256 index = 0; index < memberedProject.length; index++) {
            if (memberedProject[index] == projectId_) {
                foundedIndex = true;
            }
        }
        if (!foundedIndex) {
            _memberdProject[msg.sender].push(projectId_);
        }

        _isMemberClaimed[msg.sender][projectId_] = false;
        emit AddProjectMember(projectId_, msg.sender, referral_, price);
    }

    function claim(uint256 projectId_) public {
        address projectAddress = _xtatuzFactory.getProjectAddress(projectId_);

        IXtatuzProject(projectAddress).claim(msg.sender);

        _isMemberClaimed[msg.sender][projectId_] = true;
        _triggerTimestamp[msg.sender][projectId_] = block.timestamp;

        emit Claimed(projectId_, msg.sender);
    }

    function refund(uint256 projectId_) public {
        uint256[] memory memberedProject = _memberdProject[msg.sender];
        address projectAddress = _xtatuzFactory.getProjectAddress(projectId_);

        

        int256 foundedIndex = -1;
        for (uint256 index = 0; index < memberedProject.length; index++) {
            if (memberedProject[index] == projectId_) {
                foundedIndex = int256(index);
            }
        }
        if (foundedIndex > -1) {
            delete _memberdProject[msg.sender][uint256(foundedIndex)];
        }

        IXtatuzProject(projectAddress).refund(msg.sender);

        emit Refunded(projectId_, msg.sender);
    }

    function nftReroll(uint256 projectId_, uint256 tokenId_) public {
        require(_rerollAddress != address(0), "ROUTER: NO_REROLL_ADDRESS");

        address propertyAddress = _xtatuzFactory.getPropertyAddress(projectId_);
        IProperty property = IProperty(propertyAddress);
        IXtatuzReroll rerollContract = IXtatuzReroll(_rerollAddress);

        string memory prevUri = property.tokenURI(tokenId_);
        uint256 fee = rerollContract.rerollFee();
        string[] memory rerollData = rerollContract.getRerollData(projectId_);        
        address tokenOwner = property.ownerOf(tokenId_);
        require(tokenOwner == msg.sender, "ROUTER: NOT_NFT_OWNER");

        uint256 newIndex = block.timestamp % rerollData.length;
        property.setTokenURI(tokenId_, rerollData[newIndex]);
        rerollData[newIndex] = prevUri;
        rerollContract.setRerollData(projectId_, rerollData);

        IERC20(xtaTokenAddress).transferFrom(msg.sender, address(this), fee);
        _totalRerollFee[projectId_] += fee;

        emit NFTReroll(msg.sender, projectId_, tokenId_);
    }

    function claimRerollFee(uint256 projectId_) public onlySpv {
        require(_totalRerollFee[projectId_] > 0, "ROUTER: OUT_OF_FEE");
        uint256 totalFee = _totalRerollFee[projectId_];
        IERC20(xtaTokenAddress).transfer(msg.sender, totalFee);
        _totalRerollFee[projectId_] = 0;
        emit ClaimedRerollFee(msg.sender, projectId_, totalFee);
    }

    function trigger(uint256 projectId_) public {
        uint256[] memory memberedProject = _memberdProject[msg.sender];
        int256 foundedIndex = -1;
        for (uint256 index = 0; index < memberedProject.length; index++) {
            if (memberedProject[index] == projectId_) {
                foundedIndex = int256(index);
            }
        }
        require(foundedIndex > -1, "PROJECT: NOT_MEMBERED");
        _triggerTimestamp[msg.sender][projectId_] = block.timestamp;

        emit Trigger(projectId_, msg.sender, _triggerTimestamp[msg.sender][projectId_]);
    }

    function buyBack(
        address member_,
        uint256 projectId_,
        uint256 tokenId_
    ) public onlySpv {
        require(_isMemberClaimed[member_][projectId_], "PROJECT: DID_NOT_CLAIMED");

        uint256 lastTrigger = _triggerTimestamp[member_][projectId_] = block.timestamp;
        require(block.timestamp > (lastTrigger + triggerPeriod), "ROUTER: IN_PERIOD");

        address propertyAddress = _xtatuzFactory.getPropertyAddress(projectId_);
        address projectAddress = _xtatuzFactory.getProjectAddress(projectId_);

        IProperty property = IProperty(propertyAddress);
        IXtatuzProject project = IXtatuzProject(projectAddress);

        uint256 marketPrice = IXtatuzPricing(_pricingAddress).marketPrice(propertyAddress, tokenId_);
        property.transferFrom(member_, _spvAddress, tokenId_);

        address tokenAddress = project.tokenAddress();
        IERC20(tokenAddress).transfer(member_, marketPrice);

        emit Buyback(projectId_, member_);
    }

    function getProjectAddressById(uint256 projectId) public view returns (address) {
        return _xtatuzFactory.getProjectAddress(projectId);
    }

    function getAllCollection() public view returns (Collection[] memory) {
        uint256[] memory projectList = _memberdProject[msg.sender];
        Collection[] memory collections = new Collection[](projectList.length);
        for (uint256 index = 0; index < projectList.length; index++) {
            if (projectList[index] > 0) {
                uint256 projectId = projectList[index];
                address projectAddress = _xtatuzFactory.getProjectAddress(projectId);
                IXtatuzProject.Status status = IXtatuzProject(projectAddress).projectStatus();
                if (status == IXtatuzProject.Status.FINISH && _isMemberClaimed[msg.sender][projectId]) {
                    address propertyAddress = _xtatuzFactory.getPropertyAddress(projectId);
                    uint256[] memory tokenList = IProperty(propertyAddress).getTokenIdList(msg.sender);
                    IProperty.PropertyStatus propStatus = IProperty(propertyAddress).propertyStatus();
                    CollectionType collecType = CollectionType(uint256(propStatus) + 1);
                    Collection memory collect = Collection({
                        contractAddress: propertyAddress,
                        tokenIdList: tokenList,
                        collectionType: collecType
                    });
                    collections[index] = collect;
                } else {
                    address presaledAddress = _xtatuzFactory.getPresaledAddress(projectId);
                    uint256[] memory tokenList = IPresaled(presaledAddress).getPresaledOwner(msg.sender);
                    Collection memory collect = Collection({
                        contractAddress: presaledAddress,
                        tokenIdList: tokenList,
                        collectionType: CollectionType.PRESALE
                    });
                    collections[index] = collect;
                }
            }
        }
        return collections;
    }

    function setRerollAddress(address rerollAddress_) public prohibitZeroAddress(rerollAddress_) onlySpv {
        _rerollAddress = rerollAddress_;
    }

    function setMembershipAddress(address membershipAddress_) public prohibitZeroAddress(membershipAddress_) onlySpv {
        _membershipAddress = membershipAddress_;
    }

    function setXtaTokenAddress(address xtaTokenAddress_) public prohibitZeroAddress(xtaTokenAddress_) onlySpv {
        xtaTokenAddress = xtaTokenAddress_;
    }

    function setPricingAddress(address pricingAddress_) public prohibitZeroAddress(pricingAddress_) onlySpv {
        _pricingAddress = pricingAddress_;
    }

    function setTriggerPeriod(uint256 period_) public onlySpv {
        triggerPeriod = period_;
    }

    function setPropertyStatus(uint256 projectId_, IProperty.PropertyStatus status) public onlySpv {
        address propertyAddress = _xtatuzFactory.getPropertyAddress(projectId_);
        IProperty(propertyAddress).setPropertyStatus(status);
        emit ChangePropertyStatus(projectId_, status);
    }

    function _transferSpv(address newSpv_) internal prohibitZeroAddress(newSpv_) {
        address prevSpv = _spvAddress;
        _spvAddress = newSpv_;
        emit SpvTransferred(prevSpv, newSpv_);
    }

    function transferSpv(address newSpv_) public onlySpv prohibitZeroAddress(newSpv_) {
        _transferSpv(newSpv_);
    }

}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IProperty.sol";

interface IXtatuzFactory {
    struct ProjectPrepareData {
        uint256 projectId_;
        address spv_;
        address trustee_;
        uint256 count_;
        address tokenAddress_;
        address membershipAddress_;
        string name_;
        string symbol_;
        IProperty.PackageDetail[] packages_;
        address routerAddress;
    }

    function createProjectContract(ProjectPrepareData memory projectData) external payable returns (address);

    function getProjectAddress(uint256 projectId_) external view returns (address);

    function getPresaledAddress(uint256 projectId_) external view returns (address);

    function getPropertyAddress(uint256 projectId_) external view returns (address);

    function allProjectAddress() external view returns (address[] memory);

    function allProjectId() external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IProperty.sol";

interface IXtatuzProject {

    enum Status {
        AVAILABLE,
        FINISH,
        REFUND,
        UNAVAILABLE
    }

    struct ProjectData {
        uint256 projectId;
        address owner;
        uint256 count;
        uint256 countReserve;
        uint256 value;
        address[] members;
        uint256 startPresale;
        uint256 endPresale;
        Status status;
        address tokenAddress;
        address propertyAddress;
        address presaledAddress;
    }

    function addProjectMember(
        address member_,
        uint256 package_,
        uint256 amount_
    ) external returns(uint256);

    function finishProject() external;

    function claim(address member_) external returns(uint256);

    function refund(address member_) external returns (uint256);

    function setPresalePeriod(uint256 startPresale_, uint256 endPresale_) external;

    function projectStatus() external view returns(Status);

    function minPrice() external returns(uint256);

    function count() external view returns(uint256);

    function countReserve() external view returns(uint256);

    function startPresale() external view returns(uint256);

    function endPresale() external view returns(uint256);

    function tokenAddress() external view returns(address);

    function transferOwnership(address owner) external;

    function multiSigMint(uint256 projectId) external;

    function multiSigBurn(uint256 projectId) external;

    function getProjectData() external view returns(ProjectData memory);

    function checkCanClaim() external view returns(bool);

    function getMemberedPackBonus(address member_) external view returns(uint256);
    
    function getMemberedEarlyBonus(address member_) external view returns(uint256);

    function packageBonus(uint256 package_) external view returns (uint256);

    function earlyBonus() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IPresaled {

    function mint(address to, uint amount, uint package) external;

    function burn(uint256[] memory tokenIdList) external;

    function getPresaledOwner(address owner) external view returns (uint[] memory);

    function getMintedTimestamp(uint tokenId) external view returns (uint);

    function getPresaledPackage(uint tokenId) external view returns (uint);

    function transferOwnership(address owner) external;

    function setBaseURI(string memory baseURI_) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IProperty {
    enum PropertyStatus {
        INCOMPLETE,
        COMPLETE
    }

    struct PackageDetail {
        uint256 nft;
        uint256 xta;
    }

    function getPackages() external view returns (PackageDetail[] memory);

    function isMintedMaster() external view returns (bool);

    function mintMaster() external;

    function burnMaster(uint256 count) external;

    function getTokenIdList(address member) external view returns (uint256[] memory);

    function mintFragment(address to, uint256 amount) external;

    function transferOwnership(address owner) external;

    function propertyStatus() external view returns (PropertyStatus);

    function setPropertyStatus(PropertyStatus status) external;

    function setTokenURI(uint256 tokenId_, string memory tokenURI_) external;

    function setApprovalForAll(address operator, bool approved) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function rerollData(uint256 index) external view returns(string memory);

    function tokenURI(uint256 tokenId_) external returns(string memory);

    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IXtatuzPricing {

    function marketPrice(address propertyAddress_, uint256 tokenId) external view returns(uint256);

    function setOperator(address operator_) external;

    function setRouterAddress(address routerAddress_) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IXtatuzReroll {

    function reroll(uint256 projectId_, uint256 tokenId_, address member_) external;

    function rerollFee() external returns(uint256);

    function getRerollData(uint256 projectId) external returns(string[] memory);

    function setRerollData(uint256 projectId_, string[] memory rerollData_) external;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
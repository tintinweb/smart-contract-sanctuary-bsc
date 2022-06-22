// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./access/Operable.sol";

contract ProjectManager is Ownable, Operable {
    
    struct Project {
        address owner;
        string name;
        string slogan;
        string shortDescription;
        string description;
        string[] images;
        string[] socialLinks;
        string auditLink;
        string docsLink;
        string website;
        string videoLink;
        string roadmap;
        string roadmapLink;
        string tokenomics;
        string tokenomicsLink;
    }

    struct Auditor {
        address auditor;
        string name;
        string image;
    }

    struct Data {
        address auditor;
        string link;
        string comments;
        bool done;
        string name;
        string image;
    }

    struct All {
        Project project;
        Data[] audits;
        Data[] quickReviews;
        Data[] kycs;
        string tokenSymbol;
        string tokenName;
        uint8 decimals;
        uint256 totalSupply;
    }

    mapping(address => Project) public projects;

    mapping(address => address[]) public ownerToTokenAddress;

    mapping(string => address) public slugToTokenAddress;

    Auditor[] public auditors;

    mapping(address => Data[]) public projectAudits;
    mapping(address => Data[]) public projectQuickReviews;
    mapping(address => Data[]) public projectKYC;

    constructor(address _operator) {
        transferOperable(_operator);
    }

    modifier onlyProjectOwner(address _tokenAddress) {
        require(
            msg.sender == projects[_tokenAddress].owner || msg.sender == owner(),
            "not project owner"
        );
        _;
    }

    modifier onlyAuditors() {
        require(_getAuditorIndex(msg.sender) < type(uint256).max);
        _;
    }



    /** VIEWS **/

    function getAuditorByAddress(address _auditor) public view returns (Auditor memory) {
        return auditors[_getAuditorIndex(_auditor)];
    }

    function getProject(address _tokenAddress) public view returns(Project memory) {
        return projects[_tokenAddress];
    }

    function getAll(address _tokenAddress) public view returns(All memory) {
        return All({
            project: projects[_tokenAddress],
            audits: projectAudits[_tokenAddress],
            quickReviews: projectQuickReviews[_tokenAddress],
            kycs: projectKYC[_tokenAddress],
            tokenSymbol: IERC20Metadata(_tokenAddress).symbol(),
            tokenName: IERC20Metadata(_tokenAddress).name(),
            decimals: IERC20Metadata(_tokenAddress).decimals(),
            totalSupply: IERC20Metadata(_tokenAddress).totalSupply()
        });
    }

    function getProjectsByOwner(address _owner) public view returns(address[] memory) {
        return ownerToTokenAddress[_owner];
    }

    function isSlug(string memory _slug) public view returns(bool) {
        return slugToTokenAddress[_slug] != address(0);
    }



    /** OWNER **/

    function addAuditor(Auditor memory _auditor) public onlyOwner {
        require(_getAuditorIndex(_auditor.auditor) == type(uint256).max);
        auditors.push(_auditor);
    }

    function removeAuditor(address _auditor) public onlyOwner {
        auditors[_getAuditorIndex(_auditor)] = auditors[auditors.length - 1];
        auditors.pop();
    }

    function setProject(address _tokenAddress, Project memory _project) public onlyOwner {
        projects[_tokenAddress] = _project;
    }

    function setProjectSlug(address _tokenAddress, string memory _slug) public onlyOwner {
        slugToTokenAddress[_slug] = _tokenAddress;
    }


    /** AUDITORS **/

    function setAuditorAuditLink(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectAudits[_tokenAddress].length; i++) {
            if (projectAudits[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory audit = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectAudits[_tokenAddress].push(audit);
        } else {
            projectAudits[_tokenAddress][index] = audit;
        }
    }

    function setAuditorQuickReview(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectQuickReviews[_tokenAddress].length; i++) {
            if (projectQuickReviews[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory quickReview = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectQuickReviews[_tokenAddress].push(quickReview);
        } else {
            projectQuickReviews[_tokenAddress][index] = quickReview;
        }
    }

    function setAuditorKYC(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectKYC[_tokenAddress].length; i++) {
            if (projectKYC[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory kyc = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectKYC[_tokenAddress].push(kyc);
        } else {
            projectKYC[_tokenAddress][index] = kyc;
        }
    }



    /** OPERATOR **/

    function addProject(address _tokenAddress, Project memory _project, string memory _slug) public onlyOperator {
        _addProject(_tokenAddress, _project, _slug);
    }

    function removeProject(address _tokenAddress) public onlyOperator {
        _removeProject(_tokenAddress);
    }

    function setProjectOwner(address _tokenAddress, address _owner) public onlyOperator {
        projects[_tokenAddress].owner = _owner;
    }
    


    /** ONLY PROJECT OWNER **/

    function setProjectSlogan(address _tokenAddress, string memory _slogan) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_slogan).length >= 20 && bytes(_slogan).length <= 100);
        projects[_tokenAddress].slogan = _slogan;
    }

    function setProjectDescription(address _tokenAddress, string memory _description) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_description).length >= 20 && bytes(_description).length <= 100);
        projects[_tokenAddress].description = _description;
    }

    function setProjectShortDescription(address _tokenAddress, string memory _shortDescription) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_shortDescription).length >= 20 && bytes(_shortDescription).length <= 100);
        projects[_tokenAddress].shortDescription = _shortDescription;
    }

    function setProjectImage(address _tokenAddress, uint256 _index, string memory _image) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].images[_index] = _image;
    }

    function setProjectImages(address _tokenAddress, string[] memory _images) public onlyProjectOwner(_tokenAddress) {
        require(_images.length >= 3, "imgs");
        projects[_tokenAddress].images = _images;
    }

    function setProjectSocialLinks(address _tokenAddress, string[] memory _socialLinks) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].socialLinks = _socialLinks;
    }

    function setProjectAuditLink(address _tokenAddress, string memory _auditLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].auditLink = _auditLink;
    }

    function setProjectDocsLink(address _tokenAddress, string memory _docsLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].docsLink = _docsLink;
    }

    function setProjectWebsite(address _tokenAddress, string memory _website) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_website).length > 15);
        projects[_tokenAddress].website = _website;
    }

    function setProjectVideoLink(address _tokenAddress, string memory _videoLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].videoLink = _videoLink;
    }

    function setProjectRoadmap(address _tokenAddress, string memory _roadmap) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].roadmap = _roadmap;
    }

    function setProjectRoadmapLink(address _tokenAddress, string memory _roadmapLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].roadmapLink = _roadmapLink;
    }

    function setProjectTokenomics(address _tokenAddress, string memory _tokenomics) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].tokenomics = _tokenomics;
    }

    function setProjectTokenomicsLink(address _tokenAddress, string memory _tokenomicsLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].tokenomicsLink = _tokenomicsLink;
    }


    /** INTERNAL **/

    function _addProject(address _tokenAddress, Project memory _project, string memory _slug) internal {
        require(bytes(_project.name).length >= 3 && bytes(_project.name).length <= 50, "name");
        require(bytes(_project.slogan).length >= 20 && bytes(_project.slogan).length <= 100, "slogan");
        require(bytes(_project.shortDescription).length >= 20 && bytes(_project.shortDescription).length <= 100, "short");
        require(bytes(_project.description).length >= 20 && bytes(_project.description).length <= 100, "descript");
        require(bytes(_project.website).length > 15, "website");
        require(_project.socialLinks.length >= 2, "socials");
        require(_project.images.length >= 3, "imgs");
        require(bytes(_slug).length > 0 && slugToTokenAddress[_slug] == address(0), "slug");

        projects[_tokenAddress] = _project;

        if (address(_project.owner) != address(0)) {
            ownerToTokenAddress[_project.owner].push(_tokenAddress);
        }
        slugToTokenAddress[_slug] = _tokenAddress;
    }

    function _removeProject(address _tokenAddress) internal {
        projects[_tokenAddress].owner = address(0);
    }



    /** INTERNAL **/ 

    function _getAuditorIndex(address _auditor) internal view returns(uint256) {
        for(uint256 i = 0; i < auditors.length; i++) {
            if (address(auditors[i].auditor) == address(_auditor)) {
                return i;
            }
        }
        return type(uint256).max;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Operable is Context {
    address public operator;

    constructor() {
        _transferOperable(_msgSender());
    }

    modifier onlyOperator() {
        require(
            operator == _msgSender(),
            "Operable: caller is not the operator"
        );
        _;
    }

    function transferOperable(address _newOperator) public onlyOperator {
        require(
            _newOperator != address(0),
            "Operable: new operator is the zero address"
        );

        _transferOperable(_newOperator);
    }

    function _transferOperable(address _newOperator) internal {
        operator = _newOperator;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
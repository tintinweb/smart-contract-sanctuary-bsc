// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {IERC20Metadata as IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CreatePrivatesaleContract {
    using Address for address;

    constructor() {}
}

interface ICreateLaunchpad {
    event createPrivatesale(
        address indexed owner,
        address indexed presaleAddress,
        uint256 startTime
    );
    event UpdatedPresale(
        address indexed owner,
        address indexed airdropAddress,
        uint256 UpdatedTime
    );
    // event StartPresale(address indexed airdropAddress,uint256 StartedTime);
    event CancelledPresale(
        address indexed airdropAddress,
        uint256 CancelledTime
    );
    enum Status {
        Upcoming,
        Live,
        inProgess,
        Filled,
        Ended,
        Cancelled
    }
    enum PaymentOpt {
        BNB,
        BUSD,
        USDC,
        USDT
    }

    enum ListingOptions {
        Auto,
        Manual
    }
    enum SaleType {
        Public,
        WhitelistOnly
    }

    // State variables
    struct PrivatesaleSection {
        Presale presale;
        PaymentOpt paymentOpt;
        SaleType saleType;
        SailInputSection sailInputSection;
        Vesting vesting;
        string logoURL;
        string website;
        Social social;
        string description;
        Status status;
        ListingOptions listingOptions;
    }

    struct SailInputSection {
        uint256 softcap;
        uint256 hardCap;
        uint256 minBnb;
        uint256 maxBnb;
        uint256 privatesaleRate;
        uint256 raisedPrivatesaleAmount;
        uint256 tokenAmount;
        uint256 startTime;
        uint256 endTime;
    }

    struct Presale {
        address presaleAddress;
        string title;
        address payable presaleOwnerAddress;
    }
    struct Vesting {
        uint256 firstFundReleasePercentage;
        uint256 releaseCycle;
        uint256 releaseEachCyclePercentage;
    }
    struct Social {
        string facebookURL;
        string twitterURL;
        string githubURL;
        string telegramURL;
        string instagramURL;
        string discordURL;
        string redditURL;
        string youtubeURL;
    }

    struct Addwhitelist {
        address[] users;
    }
}

contract factoryCreatePrivatesale is ReentrancyGuard, Ownable, ICreateLaunchpad {
    using SafeMath for uint256;
    uint256 private platformFee = 0.0001 ether;
    address[] private privatesaleAddressArray;

    mapping(address => PrivatesaleSection)
        public presaleAddressToCreatePresaleDetail;
    // mapping(address=>PrivatesaleSection[]) private _presaleAddressToPresaleDetailList; // presale Detail list
    mapping(address => Addwhitelist) private presaleAddressToAddwhitelistDetail;
    mapping(address => mapping(address => uint256))
        public PrivatesaleAddressToUserToBuyTokenAmount;
    mapping(address => mapping(address => uint256))
        private userToPresaleAddressToClaimed;
    mapping(address => mapping(address => uint256))
        public userToPresaleAddressToLastClaimedTime;

    // Modifier Section

    modifier onlyPrivatesaleOwner(address _presaleAddress) {
        require(
            msg.sender ==
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .presale
                    .presaleOwnerAddress,
            "only Airdrop Owner can call this method"
        );
        _;
    }

    modifier isPrivatesaleLive(address _presaleAddress) {
        require(
            presaleAddressToCreatePresaleDetail[_presaleAddress].status ==
                Status.Live ||
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .startTime <=
                block.timestamp,
            "Privatesale is not live"
        );
        _;
    }

    modifier alreadyPrivatesaleLive(address _presaleAddress) {
        require(
            presaleAddressToCreatePresaleDetail[_presaleAddress].status !=
                Status.Live ||
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .startTime >
                block.timestamp,
            " Privatesale is already live "
        );
        _;
    }

    function CreatePrivatesale(
        string memory _title,
        PaymentOpt paymentOpt,
        SailInputSection memory _sailInputSection,
        Vesting memory _vesting,
        string memory _logoURL,
        string memory _website,
        Social memory _social,
        string memory _description
    ) external payable nonReentrant {
        require(msg.value == platformFee, "Platform fee not sufficient");
        CreatePrivatesaleContract createPrivatesaleContract = new CreatePrivatesaleContract();
        emit createPrivatesale(
            msg.sender,
            address(createPrivatesaleContract),
            block.timestamp
        );
        privatesaleAddressArray.push(address(createPrivatesaleContract));
        presaleAddressToCreatePresaleDetail[address(createPrivatesaleContract)]
            .presale
            .presaleAddress = address(createPrivatesaleContract);
        presaleAddressToCreatePresaleDetail[address(createPrivatesaleContract)]
            .presale
            .title = _title;
        presaleAddressToCreatePresaleDetail[address(createPrivatesaleContract)]
            .presale
            .presaleOwnerAddress = payable(msg.sender);
        privateSaleDetailFill(
            address(createPrivatesaleContract),
            paymentOpt,
            _sailInputSection,
            _vesting
        );
        addSocialMediaDetail(
            address(createPrivatesaleContract),
            _logoURL,
            _website,
            _social,
            _description
        );
    }

    function privateSaleDetailFill(
        address _presaleAddress,
        //  SaleType saleType,
        PaymentOpt paymentOpt,
        SailInputSection memory _sailInputSection,
        Vesting memory _vesting
    ) internal onlyPrivatesaleOwner(_presaleAddress) {
        presaleAddressToCreatePresaleDetail[_presaleAddress]
            .paymentOpt = paymentOpt;
        presaleAddressToCreatePresaleDetail[_presaleAddress]
            .sailInputSection = SailInputSection(
            _sailInputSection.softcap,
            _sailInputSection.hardCap,
            _sailInputSection.minBnb,
            _sailInputSection.maxBnb,
            _sailInputSection.privatesaleRate,
            _sailInputSection.raisedPrivatesaleAmount,
            _sailInputSection.tokenAmount,
            _sailInputSection.startTime,
            _sailInputSection.endTime
        );
        presaleAddressToCreatePresaleDetail[_presaleAddress].vesting = Vesting(
            _vesting.firstFundReleasePercentage,
            _vesting.releaseCycle,
            _vesting.releaseEachCyclePercentage
        );
    }

    // saleType choice public or WhitelistOnly in privateSaleDetailFillSection
    function changeSaleType(address _presaleAddress,SaleType saleType)
        external
        onlyPrivatesaleOwner(_presaleAddress)
        alreadyPrivatesaleLive(_presaleAddress)
    {
        if (
            presaleAddressToCreatePresaleDetail[_presaleAddress].saleType ==
            SaleType.Public
        ) {
            presaleAddressToCreatePresaleDetail[_presaleAddress].saleType ==
                SaleType.WhitelistOnly;
        } else {
            presaleAddressToCreatePresaleDetail[_presaleAddress]
                .saleType = SaleType.Public;
        }
    }

    // add social media URL Detail createing Privatesale
    function addSocialMediaDetail(
        address _presaleAddress,
        string memory _logoURL,
        string memory _website,
        Social memory _social,
        string memory _description
    ) internal onlyPrivatesaleOwner(_presaleAddress) {
        presaleAddressToCreatePresaleDetail[_presaleAddress].logoURL = _logoURL;
        presaleAddressToCreatePresaleDetail[_presaleAddress].website = _website;
        presaleAddressToCreatePresaleDetail[_presaleAddress].social = Social(
            _social.facebookURL,
            _social.twitterURL,
            _social.githubURL,
            _social.telegramURL,
            _social.instagramURL,
            _social.discordURL,
            _social.redditURL,
            _social.youtubeURL
        );
        presaleAddressToCreatePresaleDetail[_presaleAddress]
            .description = _description;
    }

    // Edit private sale Detail
    function editPrivateSale(
        address _presaleAddress,
        string memory _logoURL, // the logo img of the Presale (ipfs link)
        string memory _website, // link
        Social memory social,
        string memory _description
    ) external onlyPrivatesaleOwner(_presaleAddress) {
        require(
            bytes(_logoURL).length > 0 &&
                bytes(_website).length > 0 &&
                bytes(_description).length > 0,
            "These are mandatory field"
        );
        PrivatesaleSection
            storage PrivatesaleSectionStruct = presaleAddressToCreatePresaleDetail[
                _presaleAddress
            ];
        require(
            PrivatesaleSectionStruct.status == Status.Upcoming ||
                PrivatesaleSectionStruct.status == Status.Live ||
                PrivatesaleSectionStruct.sailInputSection.startTime <=
                block.timestamp,
            "You can only edit airdrop during airdrop upcoming or  live"
        );
        PrivatesaleSectionStruct.logoURL = _logoURL;
        PrivatesaleSectionStruct.website = _website;
        PrivatesaleSectionStruct.social = Social(
            social.facebookURL,
            social.twitterURL,
            social.githubURL,
            social.telegramURL,
            social.instagramURL,
            social.discordURL,
            social.redditURL,
            social.youtubeURL
        );
        PrivatesaleSectionStruct.description = _description;
    }

    // cancel Private sale function
    function cancelledPrivatesale(address _presaleAddress)
        external
        onlyPrivatesaleOwner(_presaleAddress)
    {
        PrivatesaleSection
            storage PrivatesaleSectionStruct = presaleAddressToCreatePresaleDetail[
                _presaleAddress
            ];
        require(
            PrivatesaleSectionStruct.status == Status.Upcoming ||
                PrivatesaleSectionStruct.status == Status.Live ||
                PrivatesaleSectionStruct.sailInputSection.startTime <=
                block.timestamp,
            "You can only cancelled airdrop during airdrop upcoming or  live"
        );
        presaleAddressToCreatePresaleDetail[_presaleAddress].status = Status
            .Cancelled;
    }

    // Add Whitelist in private sale contract
    function addWhitelist(
        address _presaleAddress,
        address[] calldata _userAddress
    ) external onlyPrivatesaleOwner(_presaleAddress) {
        PrivatesaleSection
            storage PrivatesaleSectionStruct = presaleAddressToCreatePresaleDetail[
                _presaleAddress
            ];
        require(
            PrivatesaleSectionStruct.status == Status.Upcoming ||
                PrivatesaleSectionStruct.status == Status.Live ||
                PrivatesaleSectionStruct.sailInputSection.startTime <=
                block.timestamp,
            "you can only set Whitelist detail when privatesale is  live"
        );
        Addwhitelist
            storage addwhitelistDetail = presaleAddressToAddwhitelistDetail[
                _presaleAddress
            ];
        uint256 addressLength = _userAddress.length;
        for (uint256 i = 0; i < addressLength; ++i) {
            addwhitelistDetail.users.push(_userAddress[i]);
        }
    }

    // Remove Whitelist in PrivateSale contract
    function removeWhitelist(address _presaleAddress)
        external
        onlyPrivatesaleOwner(_presaleAddress)
    {
        PrivatesaleSection
            memory PrivatesaleSectionStruct = presaleAddressToCreatePresaleDetail[
                _presaleAddress
            ];
        require(
            PrivatesaleSectionStruct.status == Status.Upcoming ||
                PrivatesaleSectionStruct.status == Status.Live ||
                PrivatesaleSectionStruct.sailInputSection.startTime <=
                block.timestamp,
            "you can only set Whitelist during Privatesale upcoming or live"
        );
        delete presaleAddressToAddwhitelistDetail[_presaleAddress];
    }

    // get all whitelistDetail
    function getAllWhitelistDetail(address _presaleAddress)
        external
        view
        returns (uint256 userLength)
    {
        Addwhitelist
            memory addwhitelistDetail = presaleAddressToAddwhitelistDetail[
                _presaleAddress
            ];
        uint256 _userLength = addwhitelistDetail.users.length;
        return (_userLength);
    }

    // Buy Method 2 parts
    function buyPrivatesale(address _presaleAddress, uint256 _privatesaleRate)
        external
        payable
        nonReentrant
    {
        require(
            presaleAddressToCreatePresaleDetail[_presaleAddress].status ==
                Status.Live ||
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .startTime <=
                block.timestamp,
            "Not Live"
        );
        require(
            presaleAddressToCreatePresaleDetail[_presaleAddress].status !=
                Status.Ended ||
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .endTime >
                block.timestamp,
            "Ended"
        );
        if (
            presaleAddressToCreatePresaleDetail[_presaleAddress].paymentOpt ==
            PaymentOpt.BNB
        ) {
            buyPrivatesaleWithNativeCoin(_presaleAddress);
        }
    }

    function buyPrivatesaleWithNativeCoin(address _presaleAddress) internal {
        require(
            msg.value >=
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .minBnb &&
                msg.value <=
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .maxBnb,
            "Invalid"
        );
        uint256 quantity = msg.value.mul(
            presaleAddressToCreatePresaleDetail[_presaleAddress]
                .sailInputSection
                .privatesaleRate
        );
        require(
            quantity <=
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .hardCap,
            "Filled"
        );
        // require(quantity <= presaleAddressToCreatePresaleDetail[_presaleAddress].tokenAmount,"Unavailable");
        require(
            PrivatesaleAddressToUserToBuyTokenAmount[_presaleAddress][
                msg.sender
            ].add(msg.value) <=
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .maxBnb,
            "Max"
        );
        presaleAddressToCreatePresaleDetail[_presaleAddress]
            .sailInputSection
            .raisedPrivatesaleAmount = presaleAddressToCreatePresaleDetail[
            _presaleAddress
        ].sailInputSection.raisedPrivatesaleAmount.add(msg.value);
        PrivatesaleAddressToUserToBuyTokenAmount[_presaleAddress][
            msg.sender
        ] = PrivatesaleAddressToUserToBuyTokenAmount[_presaleAddress][
            msg.sender
        ].add(msg.value);
        // presaleAddressToCreatePresaleDetail[_presaleAddress].presale.tokenAmount.sub(msg.value);
    }

    // Finilized the private sale
    function FinlizedPrivateSale(address _presaleAddress)
        external
        nonReentrant
        onlyPrivatesaleOwner(_presaleAddress)
    {
        require(
            (presaleAddressToCreatePresaleDetail[_presaleAddress]
                .sailInputSection
                .raisedPrivatesaleAmount >=
                presaleAddressToCreatePresaleDetail[_presaleAddress]
                    .sailInputSection
                    .softcap),
            "Not Filled softcap and hardCap Value"
        );
        if (
            presaleAddressToCreatePresaleDetail[_presaleAddress].saleType ==
            SaleType.Public
        ) {}
        presaleAddressToCreatePresaleDetail[_presaleAddress].status = Status
            .Ended;
    }

    // ClaimPrivatesale Detail
    function ClaimPrivatesale(address _presaleAddress)
        external
        nonReentrant
        onlyPrivatesaleOwner(_presaleAddress)
    {
        uint256 _privatesaleRate = PrivatesaleAddressToUserToBuyTokenAmount[
            _presaleAddress
        ][msg.sender];
        require(
            presaleAddressToCreatePresaleDetail[_presaleAddress]
                .sailInputSection
                .startTime <=
                block.timestamp ||
                presaleAddressToCreatePresaleDetail[_presaleAddress].status ==
                Status.Ended,
            "No:finsih or ended"
        );
        require(
            userToPresaleAddressToClaimed[msg.sender][_presaleAddress] <
                _privatesaleRate,
            "All:Claimed"
        );
        require(_privatesaleRate > 0, "No:Claim");
        if (
            presaleAddressToCreatePresaleDetail[_presaleAddress]
                .vesting
                .releaseCycle == 0
        ) {
            userToPresaleAddressToLastClaimedTime[msg.sender][
                _presaleAddress
            ] = block.timestamp;
            userToPresaleAddressToClaimed[msg.sender][
                _presaleAddress
            ] = _privatesaleRate;
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    // Platform Fee set
    function setPlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }

    // Platform Fee get
    function getPlatformFee() external view returns (uint256) {
        return platformFee;
    }

    // get all Private sale Array
    function getAllPrivateSaleAddressArray()
        external
        view
        returns (address[] memory)
    {
        return privatesaleAddressArray;
    }

    // getWhitelis address details
    function getWhitelistDetail(address _presaleAddress)
        external
        view
        returns (Addwhitelist memory)
    {
        return presaleAddressToAddwhitelistDetail[_presaleAddress];
    }

    // get Privatesale Detail
    function getPresaleDetails(address _presaleAddress)
        external
        view
        returns (PrivatesaleSection memory)
    {
        return presaleAddressToCreatePresaleDetail[_presaleAddress];
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
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
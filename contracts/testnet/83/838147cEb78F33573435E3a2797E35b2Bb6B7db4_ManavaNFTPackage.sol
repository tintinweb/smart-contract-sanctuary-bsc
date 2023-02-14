/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// File: MarketplaceNftPackages/contracts/interfaces/IMintERC721Manava.sol


pragma solidity ^0.8.0;


interface IMintERC721Manava is IERC721{
    function mint(address to) external returns (uint256);
    function mint(address creator,string memory _tokenIPFSPath) external returns (uint256);
    function burn(uint256 tokenId) external;
    function _existsTokenId(uint256 tokenId)  external view returns(bool);
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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: MarketplaceNftPackages/contracts/PackagesManagement.sol


pragma solidity ^0.8.0;



abstract contract PackagesManagement is Ownable {
    uint256 private nextPackageId;
    address treasury;
    uint256 treasuryPercentage;
    IMintERC721Manava nft;
    address operator;
    IERC20 busd;
    IERC20 manava;
    IERC20 nava;
    mapping(uint256 => uint256) public tokenIdToAmountToken;
    mapping(uint256 => string) public amountTokenToIpfs;
    mapping(uint256 => address) public packageIdToOwner;
    mapping(uint256 => mapping(uint256 => uint256)) public amountTokenForRoundIdToApyInWei;
    mapping(uint256 => Round) public roundIdToRound;
    mapping(uint256 => Package) public packageIdToPackage;
    mapping(uint256=>uint256)public tokenIdToPackageId;
    struct Round {
        uint256 dateStart;
        uint256 dateEnd;
        bool ended;
        uint256 pricePerToken;
        uint256 limitManav;
        uint256 amountManav;
        uint256 vestingPercentage;
        uint256 startVesting;
    }

    struct Package {
        uint256 roundId;
        uint256 tokenId;
        uint256 apy;
        bool apyDecreased;
        uint256 createTimestamp;
        uint256 amountTokenRemained;
        uint256 amountToken;
        uint256 amountTokenRewardStaking;
    }

    event buyPackageEvent(
        uint256 packageId,
        uint256 tokenId,
        address owner,
        uint256 round
    );
    event packageChangeOwner(
        uint256 packageId,
        address owner
    );
     event packagePurchaseChangeIpfs(
        uint256 amountToken,
        string ipfs
    );
    event createRoundEvent(
        uint256 roundNumber,
        uint256 dateStart,
        uint256 dateEnd,
        uint256 pricePerToken,
        uint256 limitManav,
        uint256 vestingPercentage,
        uint256 startVesting
    );
    event createPackageEvent(
        string ipfs,
        uint256 apy,
        uint256 round,
        uint256 amountToken
    );
    event roundEnded(uint256 round);

    modifier existsPackage(uint256 packageId) {
        require(
            bytes32(packageIdToPackage[packageId].tokenId).length > 0,
            "Package not found"
        );
        _;
    }
    modifier existsRound(uint256 roundId) {
        require(roundIdToRound[roundId].limitManav > 0, "Round not found");
        _;
    }

    constructor(
        address nftContract,
        address erc20Manava,
        address erc20Busd,
        address erc20Nava,
        address operatorInit,
        address _treasury
    ) {
        manava = IERC20(erc20Manava);
        treasuryPercentage=31;
        treasury = _treasury;
        busd = IERC20(erc20Busd);
        nava = IERC20(erc20Nava);
        nft = IMintERC721Manava(nftContract);
        nextPackageId = 1;
        operator=operatorInit;
    }

    /**
     * @notice Create a new round.
     */
    function createRound(
        uint256 roundNumber,
        uint256 dateStart,
        uint256 dateEnd,
        uint256 limitManav,
        uint256 pricePerToken,
        uint256 startVesting,
        uint256 vestingPercentage
    ) public onlyOwner {
        require(
            bytes32(roundIdToRound[roundNumber].dateStart).length > 0,
            "Round already exists"
        );
        require(roundNumber > 0, "Round cannot be less than or equal to zero");
        roundIdToRound[roundNumber] = Round(
            dateStart,
            dateEnd,
            false,
            pricePerToken,
            limitManav,
            0,
            vestingPercentage,
            startVesting
        );
        emit createRoundEvent(
            roundNumber,
            dateStart,
            dateEnd,
            pricePerToken,
            limitManav,
            vestingPercentage,
            startVesting
        );
    }

    function roundEarlyEnded(uint256 roundNumber) public onlyOwner {
	    Round memory round = roundIdToRound[roundNumber];
        _roundEnd(round,roundNumber);
	    roundIdToRound[roundNumber] = round;
        emit roundEnded(roundNumber);
    }

    //100000000000000000wei = 0.1% --> apy and amount token in WEI
    function createPackage(
        uint256 roundId,
        uint256 apy,
        uint256 amountToken,
        string memory ipfs
    ) public onlyOwner {
        require(roundIdToRound[roundId].dateEnd >= block.timestamp, "Round ended");
        amountTokenForRoundIdToApyInWei[amountToken][roundId] = apy;
        amountTokenToIpfs[amountToken]=ipfs;
        emit createPackageEvent(ipfs, apy, roundId,amountToken);
    }

    /**
     * @notice Allows a creator to mint an NFT.
     */
    function buyPackage(uint256 round, uint256 _amount)
        public
        existsRound(round)
    {
        require(
            bytes(amountTokenToIpfs[_amount]).length > 0,
            "Not valid amount"
        );
        Round memory roundOne = roundIdToRound[round];
        require(roundOne.dateEnd >= block.timestamp,"round ended");
        require(
            busd.balanceOf(msg.sender) >= (_amount * roundOne.pricePerToken),
            "Not enough balance"
        );
        require(
            busd.allowance(msg.sender, address(this)) >=
                (_amount * roundOne.pricePerToken),
            "Not enough allowance"
        );
        require(roundOne.amountManav < roundOne.limitManav, "Round limit");

        busd.transferFrom(
            msg.sender,
            address(this),
            roundOne.pricePerToken * _amount
        );

        busd.transfer(treasury,(roundOne.pricePerToken * _amount) / 100 * treasuryPercentage);
        uint256 tokenId=nft.mint(msg.sender,amountTokenToIpfs[_amount]);
        uint256 amountTokenRewardStaking = increaseAmountCoinRound(round, _amount);
        Package memory package = Package(
            round,
            tokenId,
            amountTokenForRoundIdToApyInWei[_amount][round],
            false,
            block.timestamp,
            _amount,
            _amount,
            amountTokenRewardStaking
        );

        packageIdToPackage[nextPackageId] = package;
        packageIdToOwner[nextPackageId] = msg.sender;
        tokenIdToPackageId[tokenId]=nextPackageId;
        tokenIdToAmountToken[tokenId]=_amount;
        emit buyPackageEvent(nextPackageId,tokenId, msg.sender, round);
        nextPackageId++;
    }

    function buyPackageFromOperator(uint256 round, uint256 _amount,address to,uint256 timestamp)
    public
    existsRound(round)
    {
        require(
            bytes(amountTokenToIpfs[_amount]).length > 0,
            "Not valid amount"
        );
        require(msg.sender==operator,"Permission denied");
        Round memory roundOne = roundIdToRound[round];
        require(roundOne.amountManav < roundOne.limitManav, "Round limit");
        uint256 tokenId=nft.mint(to,amountTokenToIpfs[_amount]);
        uint256 amountTokenRewardStaking = increaseAmountCoinRound(round, _amount);
        Package memory package = Package(
                round,
                tokenId,
                amountTokenForRoundIdToApyInWei[_amount][round],
                false,
                timestamp,
                _amount,
                _amount,
                amountTokenRewardStaking
        );

        packageIdToPackage[nextPackageId] = package;
        packageIdToOwner[nextPackageId] = to;
        tokenIdToPackageId[tokenId]=nextPackageId;
        tokenIdToAmountToken[tokenId]=_amount;
        emit buyPackageEvent(nextPackageId,tokenId, to, round);
        nextPackageId++;
    }

    function withdrawErc20(address coin,uint256 amount)public onlyOwner{
        IERC20(coin).transfer(msg.sender,amount);
    }

    function increaseAmountCoinRound(
        uint256 roundId,
        uint256 amountToken
    ) internal returns(uint256){
        Round memory round=roundIdToRound[roundId];
        uint256 rewardInSeconds = calculateApyInSeconds(
            amountTokenForRoundIdToApyInWei[amountToken][roundId],
            amountToken
        );
        round.amountManav += amountToken; // Payout for the whole round and amountToken
        if (round.amountManav >= round.limitManav) {
	        _roundEnd(round,roundId);
        }
        roundIdToRound[roundId] = round;
        return ((rewardInSeconds * (round.startVesting - block.timestamp))/1e18);
    }

	function _roundEnd(Round memory round,uint256 roundId) internal {
		round.ended = true;
		round.dateEnd = block.timestamp;
		if(roundIdToRound[roundId+1].dateStart > 0){
			roundIdToRound[roundId+1].dateStart = block.timestamp;
		}
		emit roundEnded(roundId);
	}

     function changeOwnerPackage(uint256 tokenId,address to) public {
         require(address(nft) == msg.sender, "You are not permission");
         if(tokenIdToPackageId[tokenId]!=0){
            packageIdToOwner[tokenIdToPackageId[tokenId]]=to;
         }
     }

     function changeNftMint(address mintAddress) public onlyOwner{
         nft=IMintERC721Manava(mintAddress);
     }

     function changeManav(address manavAddress) public onlyOwner{
         manava=IERC20(manavAddress);
     }

    function changeNava(address navaAddress) public onlyOwner{
        nava=IERC20(navaAddress);
    }

     function changeBusd(address busdAddress) public onlyOwner{
         busd=IERC20(busdAddress);
     }

     function changeOperator(address operatorInit) public onlyOwner{
         operator=operatorInit;
     }

     function changeRoundCost(uint256 cost,uint256 roundNumber) public onlyOwner {
        roundIdToRound[roundNumber].pricePerToken = cost;
    }

    function changeRoundLimitManava(uint256 limit,uint256 roundNumber) public onlyOwner {
        roundIdToRound[roundNumber].limitManav = limit;
    }

    function changeRoundStartDate(uint256 date,uint256 roundNumber) public onlyOwner {
        roundIdToRound[roundNumber].dateStart = date;
    }

    function changeRoundEndDate(uint256 date,uint256 roundNumber) public onlyOwner {
        roundIdToRound[roundNumber].dateEnd = date;
    }

    function changeIpfs(uint256 amountToken,string memory ipfs) public onlyOwner {
        amountTokenToIpfs[amountToken] = ipfs;
    }
    function changeTreasuryPercentage(uint256 percentage) public onlyOwner {
        treasuryPercentage = percentage;
    }
    function changeTreasury(address _treasury) public onlyOwner { 
        treasury = _treasury;
    }
    function changeApyInPackage(uint256[] memory amountsToken,uint256 roundId,uint256[] memory apy) public onlyOwner{
        require(amountsToken.length==apy.length,"Not valid argument");
        require(
            roundIdToRound[roundId].dateEnd >= block.timestamp,
            "Round ended"
        );
        for(uint256 i=0;i<amountsToken.length;i++){
            amountTokenForRoundIdToApyInWei[amountsToken[i]][roundId]=apy[i];
        }
    }

    function calculateApyInSeconds(uint256 apy, uint256 amountToken)
        public
        pure
        returns (uint256)
    {
        return ((((amountToken) * (apy / 24 / 60 / 60)) / 100));
    }

    function checkRoundApy(Package memory package,uint256 packageId) internal {
        if(roundIdToRound[package.roundId].dateEnd <= block.timestamp && !package.apyDecreased){
            package.apyDecreased = true;
            package.apy = package.apy / 2;
	          package.amountTokenRewardStaking = recalculatePackage(packageId,package.apy);
        }
    }

    function recalculatePackage(uint256 packageId,uint256 apy) internal returns(uint256){
	    Package memory packageOne = packageIdToPackage[packageId];
	    uint256 rewardInSeconds = calculateApyInSeconds(
		    apy,
		    packageOne.amountToken
	    );
	    uint256 rewardRoundToVesting = packageOne.amountTokenRewardStaking -
	    ((rewardInSeconds *
	    (roundIdToRound[packageOne.roundId].startVesting - roundIdToRound[packageOne.roundId].dateEnd))
	    /1e18);
	    return (rewardRoundToVesting);
    }

    function setVestingPercentage(uint256 roundId,uint256 percentage) public onlyOwner{
        roundIdToRound[roundId].vestingPercentage = percentage;
    }
    function setStartVesting(uint256 roundId,uint256 startDate) public onlyOwner{
        roundIdToRound[roundId].startVesting = startDate;
    }
	function getAmountToken(uint256 tokenId) public view returns(uint256){
		return tokenIdToAmountToken[tokenId];
	}
}

// File: MarketplaceNftPackages/contracts/NFTPackageStaking.sol


pragma solidity ^0.8.0;


abstract contract NFTPackageStaking is PackagesManagement {
    mapping(uint256 => uint256) public packageIdToLastClaim;
    mapping(uint256 => bool) public packageIdToRewardEnded;

    event Claim(
        address indexed sender,
        uint256 tokenId,
        uint256 reward,
        uint256 timestamp
    );
    event LastClaim(uint256 tokenId);

    function calculateApy(uint256 packageId,uint256 apy)
        public
        view
        existsPackage(packageId)
        returns (uint256)
    {
        Package memory packageOne = packageIdToPackage[packageId];
        uint256 dateStart;
        uint256 dateEnd;
        if (packageIdToLastClaim[packageId] > 0) {
            dateStart = packageIdToLastClaim[packageId];
        } else {
            dateStart = packageOne.createTimestamp;
        }
        if (block.timestamp >= roundIdToRound[packageOne.roundId].dateEnd) {
            dateEnd = roundIdToRound[packageOne.roundId].dateEnd;
        } else {
            dateEnd = block.timestamp;
        }
        if(dateEnd <= dateStart){
            return 0;
        }
        uint256 diff = dateEnd - dateStart;
        uint256 reward = calculateApyInSeconds(apy, packageOne.amountToken);
        return ((reward * diff) / 1e18);
    }
    function calculateApyToEndRound(uint256 packageId,uint256 apy) public view returns(uint256){
        Package memory packageOne = packageIdToPackage[packageId];
        uint256 dateStart;
        uint256 dateEnd;
        Round memory round = roundIdToRound[packageIdToPackage[packageId].roundId];

        if(block.timestamp <= round.dateEnd){
            return 0;
        }
        if(block.timestamp >= round.startVesting){
            return packageOne.amountTokenRewardStaking;
        }
        if(packageIdToLastClaim[packageId] < round.dateEnd) {
            dateStart = round.dateEnd;
        }else{
            dateStart = packageIdToLastClaim[packageId];
        }

        if(block.timestamp >= round.startVesting){
            dateEnd = round.startVesting;
        }else{
            dateEnd = block.timestamp;
        }

        uint256 diff = dateEnd - dateStart;
        uint256 reward = calculateApyInSeconds(apy, packageOne.amountToken);
        return ((reward * diff) / 1e18);

    }
    function claimRewardStaking(uint256 packageId)
        public
        existsPackage(packageId)
    {
        Package memory packageOne = packageIdToPackage[packageId];
        require(!packageIdToRewardEnded[packageId], "Staking ended");
        require(
            packageIdToOwner[packageId] == msg.sender,
            "It's not your package"
        );
        uint256 rewardStakingRound = calculateApy(packageId,packageOne.apy);
        checkRoundApy(packageOne,packageId);
        uint256 rewardStakingRoundEnd = calculateApyToEndRound(packageId,packageOne.apy);
        uint256 reward = rewardStakingRound + rewardStakingRoundEnd;
        uint256 roundEnd = roundIdToRound[packageIdToPackage[packageId].roundId]
            .dateEnd;
        if (packageOne.amountTokenRewardStaking <= reward) {
            packageOne.amountTokenRewardStaking = 0;
            packageIdToRewardEnded[packageId] = true;
            emit LastClaim(packageIdToPackage[packageId].tokenId);
        }else {
            packageOne.amountTokenRewardStaking -=reward;
        }
        packageIdToPackage[packageId] = packageOne;
        packageIdToLastClaim[packageId] = block.timestamp;
        nava.transfer(msg.sender, reward);
        emit Claim(msg.sender,packageOne.tokenId,reward,block.timestamp);
    }
}

// File: MarketplaceNftPackages/contracts/PackagesVesting.sol


pragma solidity ^0.8.0;



abstract contract PackagesVesting is PackagesManagement, NFTPackageStaking {
    mapping(uint256 => uint256) public packageIdToLastRewardVesting;
    event ClaimVesting(
        address indexed sender,
        uint256 tokenId,
        uint256 reward,
        uint256 timestamp);
    event createRoundVestingPercentageAndStartDate(
        uint256 roundId,
        uint256 percentage,
        uint256 startDate
    );
    event updateRoundVestingPercentage(
        uint256 roundId,
        uint256 percentage
    );
    event updateRoundStartDate(
        uint256 roundId,
        uint256 startDate
    );

    function calculateVesting(uint256 packageId)
        public
        view
        existsPackage(packageId)
        returns (uint256)
    {
    
        uint256 dateStart;
        Package memory packageOne = packageIdToPackage[packageId];
        Round memory round=roundIdToRound[packageOne.roundId];
        if (packageIdToLastRewardVesting[packageId] > 0) {
            dateStart = packageIdToLastRewardVesting[packageId];
        } else {
            dateStart = round.startVesting;
        }
        uint256 diff = block.timestamp - dateStart;
        uint256 reward = calculateVestingInSeconds(
            round.vestingPercentage,
            packageOne.amountToken
        );
        //check if more days have passed than necessary, then we pay the rest
        if (((reward* diff)) >= packageOne.amountTokenRemained) {
            return packageOne.amountTokenRemained;
        }
        return (((reward * diff)));
    }
    function claimRewardVesting(uint256 packageId)
        public
        existsPackage(packageId)
    {
        require(
            packageIdToOwner[packageId] == msg.sender,
            "It's not your package"
        );
        Package memory packageOne = packageIdToPackage[packageId];
        require(packageIdToRewardEnded[packageId] 
        || 
        amountTokenForRoundIdToApyInWei[packageOne.amountToken][
            packageOne.roundId
        ]==0, "Claim staking first");
        Round memory round=roundIdToRound[packageOne.roundId];
        require(
            round.startVesting <= block.timestamp,
            "Cliff is still going"
        );
        uint256 reward = calculateVesting(packageId);

        if (packageOne.amountTokenRemained - reward <= 0) {
            revert("Vesting is ended");
        }else{
            packageOne.amountTokenRemained-=reward;
            packageIdToPackage[packageId]=packageOne;
        }
        packageIdToLastRewardVesting[packageId] = block.timestamp;
        manava.transfer(msg.sender, reward);
        emit ClaimVesting(msg.sender,packageOne.tokenId,reward,block.timestamp);
    }

    function calculateVestingInSeconds(uint256 percentage, uint256 amountToken)
        public
        pure
        returns (uint256)
    {
        return (((amountToken / 30 / 24 / 60 / 60) * (percentage)) / 100);
    }

}

// File: MarketplaceNftPackages/contracts/ManavaNFTPackage.sol


pragma solidity ^0.8.0;




contract ManavaNFTPackage is
    PackagesManagement,
    NFTPackageStaking,
    PackagesVesting
{
    constructor(
        address nftContract,
        address erc20Manava,
        address erc20Busd,
        address erc20Nava,
        address operator,
        address treasury
    ) PackagesManagement(nftContract, erc20Manava, erc20Busd, erc20Nava, operator, treasury) {}
}
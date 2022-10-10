// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../shared/TokenTransfers.sol";

import "./mixins/StashMarketBuy.sol";
import "./mixins/StashMarketCore.sol";
import "./mixins/StashMarketFees.sol";
import "./mixins/StashMarketLender.sol";
import "./mixins/StashMarketRenter.sol";
import "./mixins/StashMarketTerms.sol";

/**
 * @title The Stash Market for renting and buying NFTs.
 * @author batu-inal & HardlyDifficult
 */
contract StashMarket is
  TokenTransfers,
  StashMarketCore,
  StashMarketFees,
  StashMarketTerms,
  StashMarketLender,
  StashMarketRenter,
  StashMarketBuy
{
  /**
   * @notice Assign immutable variables defined in this proxy's implementation.
   * @param _weth The address of the WETH contract for this network.
   * @param _treasury The address to which payments to Stash should be sent.
   * @param _feeInBasisPoints The fee percentage for the Stash treasury, in basis points.
   */
  constructor(
    address payable _weth,
    address payable _treasury,
    uint16 _feeInBasisPoints
  )
    TokenTransfers(_weth)
    StashMarketFees(_treasury, _feeInBasisPoints) // solhint-disable-next-line no-empty-blocks
  {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../interfaces/IWeth.sol";

import "../shared/Constants.sol";

/**
 * @title Manage transfers of ETH and ERC20 tokens.
 * @dev This is a mixin instead of a library in order to support an immutable variable.
 * @author batu-inal & HardlyDifficult
 */
abstract contract TokenTransfers {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using AddressUpgradeable for address payable;

  /**
   * @notice The WETH contract address on this network.
   */
  address payable public immutable weth;

  /**
   * @notice Assign immutable variables defined in this proxy's implementation.
   * @param _weth The address of the WETH contract for this network.
   */
  constructor(address payable _weth) {
    require(_weth.isContract(), "TokenTransfers: WETH is not a contract");
    weth = _weth;
  }

  /**
   * @notice Transfer funds from the msg.sender to the recipient specified.
   * @param to The address to which the funds should be sent.
   * @param paymentToken The ERC-20 token to be used for the transfer, or address(0) for ETH.
   * @param amount The amount of funds to be sent.
   * @dev When ETH is used, the caller is required to confirm that the total provided is as expected.
   */
  function _transferFunds(
    address to,
    address paymentToken,
    uint256 amount
  ) internal {
    // TODO: push this logic up, like we did in play rewards?
    if (amount == 0) {
      return;
    }
    require(to != address(0), "TokenTransfers: to is required");

    if (paymentToken == address(0)) {
      // ETH
      // Cap the gas to prevent consuming all available gas to block a tx from completing successfully
      // solhint-disable-next-line avoid-low-level-calls
      (bool success, ) = to.call{ value: amount, gas: SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT }("");
      if (!success) {
        // Store the funds that failed to send for the user in WETH
        IWeth(weth).deposit{ value: amount }();
        IWeth(weth).transfer(to, amount);
      }
    } else {
      // ERC20 Token
      require(msg.value == 0, "TokenTransfers: ETH cannot be sent with a token payment");
      IERC20Upgradeable(paymentToken).safeTransferFrom(msg.sender, to, amount);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../WrappedNFTs/interfaces/IERC4907.sol";
import "../../WrappedNFTs/interfaces/IERC5006.sol";

import "../../libraries/Time.sol";
import "../../shared/TokenTransfers.sol";

import "./StashMarketFees.sol";
import "./StashMarketTerms.sol";

/**
 * @title Allows collectors to buy an NFT from the Stash market.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketBuy is TokenTransfers, StashMarketFees, StashMarketTerms {
  using Time for uint64;

  event Bought(uint256 indexed termsId, address indexed buyer);

  // TODO: are we sure we don't want to allow 1155 amounts to be <= listed amount?
  // & set price by amount instead of the batch?
  // TODO: add a buy for? and allow any account to buy for the current renter?
  function buy(uint256 termsId) external payable {
    RentalTerms memory terms = getRentalTerms(termsId);
    require(terms.buyPrice != 0, "StashMarketBuy: Buy price must be set");
    require(
      terms.paymentToken != address(0) || msg.value == terms.buyPrice,
      "StashMarketBuy: Incorrect funds provided"
    );
    require(!terms.expiry.hasExpired(), "StashMarketBuy: Buy price expired");

    _deleteRentalTerms(termsId);
    _acquireOwnership(terms.nftType, terms.nftContract, terms.tokenId, terms.amount, terms.seller, terms.recordId);

    // send funds
    uint256 amount = terms.buyPrice;
    amount -= _payFees(terms.paymentToken, amount);
    _transferFunds(terms.seller, terms.paymentToken, amount);

    emit Bought(termsId, msg.sender);
  }

  function _acquireOwnership(
    NFTType nftType,
    address nftContract,
    uint256 tokenId,
    uint64 amount,
    address seller,
    uint256 recordId1155 // Not used for NFTType.ERC721.
  ) internal {
    if (nftType == NFTType.ERC721) {
      address renter = IERC4907(nftContract).userOf(tokenId);
      require(renter == address(0) || renter == msg.sender, "StashMarketBuy: Only the current renter can buy");
      if (renter != address(0)) {
        // End the rental agreement first
        IERC4907(nftContract).setUser(tokenId, address(0), 0);
      }

      // Transfer NFT
      IERC721(nftContract).safeTransferFrom(seller, msg.sender, tokenId);
    } else {
      // 1155
      if (recordId1155 != 0) {
        IERC5006.UserRecord memory userRecord = IERC5006(nftContract).userRecordOf(recordId1155);

        // Ignore empty records
        if (userRecord.amount != 0) {
          // TODO: is it possible that amount is not a match?

          if (!userRecord.expiry.hasExpired()) {
            // If the record has expired, anyone can delete the record and buy the NFT.
            require(userRecord.user == msg.sender, "StashMarketBuy: Only the current renter can buy");
          }
          // End the rental agreement first
          // 5006 tokens may not automatically remove expired records, if non-zero amount returned assume delete is
          // required even if the record is expired.
          IERC5006(nftContract).deleteUserRecord(recordId1155);
        }
      }

      // Transfer NFT
      // TODO: support user defined amount (maybe it must match how much they had rented)
      IERC1155(nftContract).safeTransferFrom(seller, msg.sender, tokenId, amount, "");
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title A place for common modifiers and functions used by various market mixins, if any.
 * @dev This also leaves a gap which can be used to add a new mixin to the top of the inheritance tree.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketCore {
  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1000] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../shared/Constants.sol";
import "../../shared/TokenTransfers.sol";

/**
 * @title Calculates and distributes Stash market protocol fees.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketFees is TokenTransfers {
  /**
   * @notice The address to which payments to Stash should be sent.
   */
  address payable public immutable treasury;

  /**
   * @notice Thee fee percentage to be paid for the Stash treasury, in basis points.
   */
  uint16 public immutable feeInBasisPoints;

  /**
   * @notice Assign immutable variables defined in this proxy's implementation.
   * @param _treasury The address to which payments to Stash should be sent.
   * @param _feeInBasisPoints The fee percentage for the Stash treasury, in basis points.
   */
  constructor(address payable _treasury, uint16 _feeInBasisPoints) {
    require(
      _feeInBasisPoints == 0 ? _treasury == address(0) : _treasury != address(0),
      "StashMarketFees: treasury is required when fees are defined"
    );
    require(_feeInBasisPoints < BASIS_POINTS, "StashMarketFees: fee basis points cannot be >= 100%");

    treasury = _treasury;
    feeInBasisPoints = _feeInBasisPoints;
  }

  /**
   * @notice Distributes fees to the treasury, from funds provided by the msg.sender.
   * @param paymentToken The ERC-20 token to be used for payment, or address(0) for ETH.
   * @param totalTransactionAmount The total price paid for the current transaction, of which fees will be taken from.
   * @return feeAmount The amount that was sent to the treasury for the protocol fee.
   */
  function _payFees(address paymentToken, uint256 totalTransactionAmount) internal returns (uint256 feeAmount) {
    feeAmount = (totalTransactionAmount * feeInBasisPoints) / BASIS_POINTS;

    // Send fees to treasury
    _transferFunds(treasury, paymentToken, feeAmount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../../WrappedNFTs/interfaces/IERC5006.sol";
import "../../WrappedNFTs/interfaces/IPlayRewardShare721.sol";
import "../../WrappedNFTs/interfaces/IPlayRewardShare1155.sol";

import "../../shared/SharedTypes.sol";
import "../../shared/TokenTransfers.sol";
import "../../libraries/Time.sol";

import "./StashMarketFees.sol";
import "./StashMarketTerms.sol";

/**
 * @title Stash Market functionality for renters.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketRenter is TokenTransfers, StashMarketFees, StashMarketTerms {
  using Time for uint64;

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapTop;

  event RentalTermsAccepted(uint256 indexed termsId, address indexed renter, uint256 rentalDays);

  // TODO: can you accept less than the full offer amount?
  // TODO: add a rent for user?
  function acceptRentalTerms(uint256 termsId, uint256 rentalDays) external payable {
    require(rentalDays != 0, "StashMarketRenter: Must rent for at least one day");
    RentalTerms memory terms = getRentalTerms(termsId);
    require(!terms.expiry.hasExpired(), "StashMarketRenter: Rental terms have expired");
    require(rentalDays <= terms.maxRentalDays, "StashMarketRenter: Rental length exceeds max rental length");

    unchecked {
      // Math is safe since rentalDays is capped by maxRentalDays which is 16 bits.
      uint64 expiry = uint64(block.timestamp + 60 * 60 * 24 * rentalDays);

      _lend(
        terms.nftType,
        terms.nftContract,
        terms.tokenId,
        terms.amount,
        terms.seller,
        expiry,
        termsId,
        // TODO: we should be able to optimize this flow
        // TODO: why isn't lenderRevShareBasisPoints uint16 in storage?
        _buildRentalRecipients(payable(terms.seller), uint16(terms.lenderRevShareBasisPoints))
      );

      // TODO: we sure we want to support free rentals?
      if (terms.pricePerDay > 0) {
        // TODO: couldn't a huge price overflow? we are unchecked here
        uint256 amount = terms.pricePerDay * rentalDays;
        require(terms.paymentToken != address(0) || msg.value == amount, "StashMarketRenter: Incorrect funds provided");
        // Math is safe since fees are always < amount provided
        amount -= _payFees(terms.paymentToken, amount);
        _transferFunds(terms.seller, terms.paymentToken, amount);
      } else {
        require(msg.value == 0, "StashMarketRenter: Incorrect funds provided");
      }
    }

    emit RentalTermsAccepted(termsId, msg.sender, rentalDays);
  }

  function _buildRentalRecipients(address payable seller, uint16 lenderRevShareBasisPoints)
    internal
    view
    returns (Recipient[] memory)
  {
    Recipient[] memory recipients = new Recipient[](2);
    // Set Stash Market as a recipient.
    recipients[0] = Recipient(treasury, feeInBasisPoints, RecipientRole.Market);
    if (lenderRevShareBasisPoints > 0) {
      // Set NFT owner as recipient.
      recipients[1] = Recipient(seller, lenderRevShareBasisPoints, RecipientRole.Owner);
    } else {
      // Chop last elt of array as owner is not a recipient.
      // solhint-disable-next-line no-inline-assembly
      assembly {
        mstore(recipients, 1)
      }
    }
    return recipients;
  }

  function _lend(
    NFTType nftType,
    address nftContract,
    uint256 tokenId,
    uint64 amount,
    address seller,
    uint64 expiry,
    uint256 termsId,
    Recipient[] memory recipients
  ) internal {
    if (nftType == NFTType.ERC721) {
      require(
        // lender must still be owner
        seller == IERC721(nftContract).ownerOf(tokenId) &&
          // nft should not be rented out
          IERC4907(nftContract).userOf(tokenId) == address(0),
        "StashMarketRenter: NFT unavailable for rent"
      );
      IERC4907(nftContract).setUser(tokenId, msg.sender, expiry);
      try
        IPlayRewardShare721(nftContract).setPlayRewardShareRecipients(tokenId, recipients)
      // solhint-disable-next-line no-empty-blocks
      {

      } catch // solhint-disable-next-line no-empty-blocks
      {

      }
    } else {
      // 1155
      require(
        // lender must still own enough amount
        // TODO switch so that the renter can choose a different amount
        // TODO: can we lean on createUserRecord to handle this requirement?
        IERC1155(nftContract).balanceOf(seller, tokenId) - IERC5006(nftContract).frozenBalanceOf(seller, tokenId) >=
          amount,
        "StashMarketRenter: NFT unavailable for rent"
      );
      uint256 recordId = IERC5006(nftContract).createUserRecord(seller, msg.sender, tokenId, amount, expiry);
      _setRecordId(termsId, recordId);
      try
        IPlayRewardShare1155(nftContract).setPlayRewardShareRecipients(recordId, recipients)
      // solhint-disable-next-line no-empty-blocks
      {

      } catch // solhint-disable-next-line no-empty-blocks
      {

      }
    }
  }

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapBottom;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../../WrappedNFTs/interfaces/IERC4907.sol";
import "../../WrappedNFTs/interfaces/IERC5006.sol";

import "../../libraries/SupportsInterfaceUnchecked.sol";
import "../../libraries/Time.sol";

import "../../shared/Constants.sol";
import "../../shared/TokenTransfers.sol";

import "../../shared/NFTTypes.sol";
import "./StashMarketCore.sol";
import "./StashMarketFees.sol";
import "./StashMarketTerms.sol";

/**
 * @title Stash Market functionality for lenders.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketLender is NFTTypes, TokenTransfers, StashMarketCore, StashMarketFees, StashMarketTerms {
  using ERC165Checker for address;
  using SupportsInterfaceUnchecked for address;
  using Time for uint64;

  event RentalTermsCancelled(uint256 indexed termsId);

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapTop;

  function cancelRentalTerms(uint256 termsId) external {
    RentalTerms memory rentalTerms = getRentalTerms(termsId);
    require(rentalTerms.seller == msg.sender, "StashMarketLender: Must be seller to cancel");

    // TODO this is inconsistent with 5006 delete - do we want to change one or the other?
    require(!rentalTerms.expiry.hasExpired(), "StashMarketLender: Cannot cancel expired rental");

    _deleteRentalTerms(termsId);
    emit RentalTermsCancelled(termsId);
  }

  function setERC721RentalTerms(
    address nftContract,
    uint256 tokenId,
    uint64 expiry,
    uint256 pricePerDay,
    uint256 lenderRevShareBasisPoints,
    uint256 buyPrice,
    address paymentToken,
    uint16 maxRentalDays
  ) external onlyERC721(nftContract, true) returns (uint256 termsId) {
    require(
      lenderRevShareBasisPoints < BASIS_POINTS - feeInBasisPoints,
      "StashMarketLender: Invalid lenderRevShareBasisPoints"
    );

    // Check eligibility to list.
    require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "StashMarketLender: Must be ownerOf NFT");
    // Approval is required in order to rent or to buy.
    require(
      IERC721(nftContract).isApprovedForAll(msg.sender, address(this)) ||
        IERC721(nftContract).getApproved(tokenId) == address(this),
      "StashMarketLender: NFT must be approved for Market"
    );

    termsId = _setRentalTerms(
      nftContract,
      tokenId,
      NFTType.ERC721,
      1,
      expiry,
      pricePerDay,
      lenderRevShareBasisPoints,
      buyPrice,
      paymentToken,
      maxRentalDays
    );
  }

  function setERC1155RentalTerms(
    address nftContract,
    uint256 tokenId,
    uint64 amount,
    uint64 expiry,
    uint256 pricePerDay,
    uint256 lenderRevShareBasisPoints,
    uint256 buyPrice,
    address paymentToken,
    uint16 maxRentalDays
  ) external onlyERC1155(nftContract, true) returns (uint256 termsId) {
    require(
      lenderRevShareBasisPoints < BASIS_POINTS - feeInBasisPoints,
      "StashMarketLender: Invalid lenderRevShareBasisPoints"
    );
    require(amount != 0, "StashMarketLender: Cannot set 0 amount");

    // 1155
    // Check eligibility to list.
    // TODO: should usableBalanceOf handle non-rented quantities as well? Does that violate the standard?
    require(
      IERC1155(nftContract).balanceOf(msg.sender, tokenId) >= amount,
      "StashMarketLender: Must own at least the amount to be lent"
    );
    // TODO support direct approvals?
    // TODO: approval only required if there's a buy price?
    require(
      IERC1155(nftContract).isApprovedForAll(msg.sender, address(this)),
      "StashMarketLender: NFT must be approved for Market"
    );

    termsId = _setRentalTerms(
      nftContract,
      tokenId,
      NFTType.ERC1155,
      amount,
      expiry,
      pricePerDay,
      lenderRevShareBasisPoints,
      buyPrice,
      paymentToken,
      maxRentalDays
    );
  }

  /**
   * @notice Checks whether a contract is rentable on the Stash Market.
   * @param nftContract The address of the checked contract.
   * @return isCompatible True if the NFT may be listed for rent in this contract.
   */
  function isCompatibleForRent(address nftContract) external view returns (bool isCompatible) {
    isCompatible = _isCompatibleForRent(nftContract);
  }

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapBottom;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../libraries/Time.sol";
import "../../shared/SharedTypes.sol";

import "../../WrappedNFTs/interfaces/IERC4907.sol";

/**
 * @title Stash Market container for rental terms and agreements.
 * @author batu-inal & HardlyDifficult
 */
abstract contract StashMarketTerms {
  using Time for uint64;

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapTop;

  /**
   * @notice A global id for rentals.
   */
  uint256 private nextTermsId;

  mapping(address => mapping(uint256 => uint256)) private erc721ContractToTokenIdToTermsId;

  mapping(uint256 => RentalTerms) private termsIdToRentalTerms;

  event RentalTermsSet(
    uint256 indexed termsId,
    address indexed nftContract,
    uint256 indexed tokenId,
    uint256 amount,
    NFTType nftType,
    address lender,
    uint256 expiry,
    uint256 pricePerDay,
    uint256 lenderRevShareBasisPoints,
    uint256 buyPrice,
    address paymentToken,
    uint256 maxRentalDays
  );

  function _deleteRentalTerms(uint256 termsId) internal {
    RentalTerms storage terms = termsIdToRentalTerms[termsId];
    // TODO Require terms found?
    if (terms.nftType == NFTType.ERC721) {
      delete erc721ContractToTokenIdToTermsId[terms.nftContract][terms.tokenId];
    }
    delete termsIdToRentalTerms[termsId];
    // TODO emit delete? Or is that assumed via events like buy?
  }

  function _setRecordId(uint256 termsId, uint256 recordId) internal {
    termsIdToRentalTerms[termsId].recordId = recordId;
  }

  function _setRentalTerms(
    address nftContract,
    uint256 tokenId,
    NFTType nftType,
    uint64 amount,
    uint64 expiry,
    uint256 pricePerDay,
    uint256 lenderRevShareBasisPoints,
    uint256 buyPrice,
    address paymentToken,
    uint16 maxRentalDays
  ) internal virtual returns (uint256 termsId) {
    // TODO: any inputs to validate? 0 pricePerDay, 0 rental days, expired?

    // Clear previous terms for this NFT if it's a 721
    if (nftType == NFTType.ERC721) {
      termsId = erc721ContractToTokenIdToTermsId[nftContract][tokenId];
      if (termsId != 0) {
        delete termsIdToRentalTerms[termsId];
      }
    }

    termsId = _getNextAndIncrementTermsId();

    if (nftType == NFTType.ERC721) {
      erc721ContractToTokenIdToTermsId[nftContract][tokenId] = termsId;
    }

    RentalTerms storage terms = termsIdToRentalTerms[termsId];
    terms.nftContract = nftContract;
    terms.tokenId = tokenId;
    terms.nftType = nftType;
    if (nftType == NFTType.ERC1155) {
      // Only save amount for 1155 tokens.
      terms.amount = amount;
    }
    terms.expiry = expiry;
    terms.pricePerDay = pricePerDay;
    terms.lenderRevShareBasisPoints = lenderRevShareBasisPoints;
    terms.buyPrice = buyPrice;
    terms.seller = msg.sender;
    terms.paymentToken = paymentToken;
    terms.maxRentalDays = maxRentalDays;

    emit RentalTermsSet(
      termsId,
      nftContract,
      tokenId,
      uint256(amount),
      nftType,
      msg.sender,
      expiry,
      pricePerDay,
      lenderRevShareBasisPoints,
      buyPrice,
      paymentToken,
      uint256(maxRentalDays)
    );
  }

  function getERC721TermsId(address nftContract, uint256 tokenId) external view returns (uint256 termsId) {
    termsId = erc721ContractToTokenIdToTermsId[nftContract][tokenId];
  }

  function getRentalTerms(uint256 termsId) public view returns (RentalTerms memory terms) {
    terms = termsIdToRentalTerms[termsId];
    if (terms.nftType == NFTType.ERC721 && terms.nftContract != address(0)) {
      // Return amount 1 for consistency, even though it's not in storage.
      terms.amount = 1;
    }
  }

  /**
   * @notice Returns id to assign to the next rental.
   */
  function _getNextAndIncrementTermsId() internal returns (uint256 id) {
    // termsId cannot overflow 256 bits.
    unchecked {
      id = ++nextTermsId;
    }
  }

  /// @notice Empty space to ease adding storage in an upgrade safe way.
  uint256[1000] private _gapBottom;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IWeth {
  function deposit() external payable;

  function transfer(address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

uint16 constant BASIS_POINTS = 10_000;

/**
 * @dev The gas limit to send ETH to multiple recipients, enough for a 5-way split.
 */
uint256 constant SEND_VALUE_GAS_LIMIT_MULTIPLE_RECIPIENTS = 210000;

/**
 * @dev The gas limit to send ETH to a single recipient, enough for a contract with a simple receiver.
 */
uint256 constant SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT = 20000;

/**
 * @dev The percent of revenue the NFT owner should receive from play reward payments generated while this NFT is
 * rented, in basis points.
 */
uint16 constant DEFAULT_OWNER_REWARD_SHARE_IN_BASIS_POINTS = 1_000; // 10%

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library Time {
  function hasExpired(uint64 expiry) internal view returns (bool) {
    return expiry < block.timestamp;
  }
}

// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.12;

/**
 * @title Rental NFT, ERC-721 User And Expires Extension
 * @dev Source: https://eips.ethereum.org/EIPS/eip-4907
 * With more elaborate comments added.
 */
interface IERC4907 {
  /**
   * @notice Emitted when the rental terms of an NFT are set or deleted.
   * @param tokenId The NFT which is being rented.
   * @param user The user who is renting the NFT.
   * The zero address for user indicates that there is no longer any active renter of this NFT.
   * @param expiry The time at which the rental expires.
   */
  event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expiry);

  /**
   * @notice Defines rental terms for an NFT.
   * @param tokenId The NFT which is being rented. Throws if `tokenId` is not valid NFT.
   * @param user The user who is renting the NFT and has access to use it in game.
   * @param expiry The time at which these rental terms expire.
   * @dev Zero for `user` and `expiry` are used to delete the current rental information, which can be done by the
   * operator which set the rental terms.
   */
  function setUser(
    uint256 tokenId,
    address user,
    uint64 expiry
  ) external;

  /**
   * @notice Get the expiry time of the current rental terms for an NFT.
   * @param tokenId The NFT to get the expiry of.
   * @return expiry The time at which the rental terms expire.
   * @dev Zero indicates that there is no longer any active renter of this NFT.
   */
  function userExpires(uint256 tokenId) external view returns (uint256 expiry);

  /**
   * @notice Get the rental user of an NFT.
   * @param tokenId The NFT to get the rental user of.
   * @return user The user which is renting the NFT and has access to use it in game.
   * @dev The zero address indicates that there is no longer any active renter of this NFT.
   */
  function userOf(uint256 tokenId) external view returns (address user);
}

// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.12;

/**
 * @title Rental NFT, NFT User Extension
 * @dev Source: https://eips.ethereum.org/EIPS/eip-5006
 * With more elaborate comments added.
 */
interface IERC5006 {
  /**
   * @notice Details about a rental.
   * @param tokenId The NFT which is being rented.
   * @param owner The owner of the NFT which was rented out.
   * @param amount The amount of the NFT which was rented to this user.
   * @param user The user who is renting the NFT.
   * @param expiry The time at which the rental expires.
   */
  struct UserRecord {
    uint256 tokenId;
    address owner;
    uint64 amount;
    address user;
    uint64 expiry;
  }

  /**
   * @notice Emitted when the rental terms of an NFT are set.
   * @param recordId A unique identifier for this rental.
   * @param tokenId The NFT which is being rented.
   * @param amount The amount of the NFT which was rented to this user.
   * @param owner The owner of the NFT which was rented out.
   * @param user The user who is renting the NFT.
   * @param expiry The time at which the rental expires.
   * @dev Emitted when permission for `user` to use `amount` of `tokenId` token owned by `owner`
   * until `expiry` are given.
   * Indexed fields are not used in order to remain consistent with the EIP.
   */
  event CreateUserRecord(uint256 recordId, uint256 tokenId, uint256 amount, address owner, address user, uint64 expiry);

  /**
   * @notice Emitted when the rental terms of an NFT are deleted.
   * @param recordId A unique identifier for the rental which was deleted.
   * @dev Indexed fields are not used in order to remain consistent with the EIP.
   * This event is not emitted for expired records.
   */
  event DeleteUserRecord(uint256 recordId);

  /**
   * @notice Creates rental terms by giving permission to `user` to use `amount` of `tokenId` token owned by `owner`
   * until `expiry`.
   * @param owner The owner of the NFT which is being rented out.
   * @param user The user who is being granted rights to use this NFT for a period of time.
   * @param tokenId The NFT which is being rented.
   * @param amount The amount of the NFT which is being rented to this user.
   * @param expiry The time at which the rental expires.
   * @return recordId A unique identifier for this rental.
   * @dev Emits a {CreateUserRecord} event.
   *
   * Requirements:
   *
   * - If the caller is not `owner`, it must be have been approved to spend ``owner``'s tokens
   * via {setApprovalForAll}.
   * - `owner` must have a balance of tokens of type `id` of at least `amount`.
   * - `user` cannot be the zero address.
   * - `amount` must be greater than 0.
   * - `expiry` must after the block timestamp.
   */
  function createUserRecord(
    address owner,
    address user,
    uint256 tokenId,
    uint64 amount,
    uint64 expiry
  ) external returns (uint256 recordId);

  /**
   * @notice Deletes previously assigned rental terms.
   * @param recordId The identifier of the rental terms to delete.
   */
  function deleteUserRecord(uint256 recordId) external;

  /**
   * @notice Return the total amount of a given token that this owner account has rented out.
   * @param account The owner of the NFT which is being rented out.
   * @param tokenId The NFT which is being rented.
   * @return amount The total amount of the NFT which is being rented out.
   * @dev Expired or deleted records are not included in the total.
   */
  function frozenBalanceOf(address account, uint256 tokenId) external view returns (uint256 amount);

  /**
   * @notice Return the total amount of a given token that this user account has rented.
   * @param account The user who is renting the NFT.
   * @param tokenId The NFT which is being rented.
   * @return amount The total amount of the NFT which is being rented to this user.
   * @dev This may include rentals for this user from multiple NFT owners.
   * Expired or deleted records are not included in the total.
   */
  function usableBalanceOf(address account, uint256 tokenId) external view returns (uint256 amount);

  /**
   * @notice Returns the rental terms for a given record identifier.
   * @param recordId The identifier of the rental terms to return.
   * @return record The rental terms for the given record identifier.
   * @dev Expired or deleted records are not returned.
   */
  function userRecordOf(uint256 recordId) external view returns (UserRecord memory record);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
pragma solidity ^0.8.12;

enum NFTType {
  ERC721,
  ERC1155
}

struct RentalTerms {
  address nftContract;
  uint256 tokenId;
  NFTType nftType;
  uint64 amount;
  uint64 expiry;
  uint256 pricePerDay;
  uint256 lenderRevShareBasisPoints;
  uint256 buyPrice;
  address paymentToken;
  address seller;
  // uint16 so that this cannot be set to an unreasonably high value
  uint16 maxRentalDays;
  // TODO: rename to include 1155 or 5006 so this is more intuitive?
  uint256 recordId;
}

enum RecipientRole {
  Player,
  Owner,
  Market,
  Other
}

/**
 * @notice Stores a recipient and their share owed for payments.
 * @param to The address to which payments should be made.
 * @param share The percent share of the payments owed to the recipient, in basis points.
 * @param role The role of the recipient in terms of why they are receiving a share of payments.
 */
struct Recipient {
  address payable to;
  uint16 shareInBasisPoints;
  RecipientRole role;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../shared/SharedTypes.sol";

/**
 * @title APIs for play rewards generated by this ERC-1155 NFT.
 * @author batu-inal & HardlyDifficult
 */
interface IPlayRewardShare1155 {
  /**
   * @notice Emitted when play rewards are paid through this contract.
   * @param tokenId The tokenId of the NFT for which rewards were paid.
   * @param to The address to which the rewards were paid.
   * There may be multiple payments for a single payment transaction, one for each recipient.
   * @param operator The account which initiated and provided the funds for this payment.
   * @param amount The amount of NFTs used to generate the rewards.
   * @param recordId The associated rental recordId, or 0 if n/a.
   * @param role The role of the recipient in terms of why they are receiving a share of payments.
   * @param paymentToken The token used to pay the rewards, or address(0) if ETH was distributed.
   * @param tokenAmount The amount of `paymentToken` sent to the `to` address.
   */
  event PlayRewardPaid(
    uint256 indexed tokenId,
    address indexed to,
    address indexed operator,
    uint256 amount,
    uint256 recordId,
    RecipientRole role,
    address paymentToken,
    uint256 tokenAmount
  );

  /**
   * @notice Emitted when additional recipients are provided for an NFT's play rewards.
   * @param recordId The recordId of the NFT rental for which reward recipients were set.
   * @param recipients The addresses to which rewards should be paid and their relative shares.
   */
  event PlayRewardRecipientsSet(uint256 indexed recordId, Recipient[] recipients);

  /**
   * @notice Pays play rewards generated by this NFT to the expected recipients.
   * @param tokenId The tokenId of the NFT for which rewards were earned.
   * @param amount The amount of NFTs used to generate the rewards.
   * @param recordId The associated rental recordId, or 0 if n/a.
   * @param recipients The address and relative share each recipient should receive.
   * @param paymentToken The token to use to pay the rewards, or address(0) if ETH will be distributed.
   * @param tokenAmount The amount of `paymentToken` to distribute to the recipients.
   * @dev If an ERC-20 token is used for payment, the `msg.sender` should first grant approval to this contract.
   */
  function payPlayRewards(
    uint256 tokenId,
    uint256 amount,
    uint256 recordId,
    Recipient[] calldata recipients,
    address paymentToken,
    uint256 tokenAmount
  ) external payable;

  /**
   * @notice Sets additional recipients for play rewards generated by this NFT.
   * @dev This is only callable while rented, by the operator which created the rental.
   * @param recordId The recordId of the NFT for which reward recipients should be set.
   * @param recipients Additional recipients and their share of play rewards to receive.
   * The user/player of the NFT will automatically be added as a recipient, receiving the remaining share - the sum
   * provided for the additional recipients must be less than 100%.
   */
  function setPlayRewardShareRecipients(uint256 recordId, Recipient[] calldata recipients) external;

  /**
   * @notice Gets the expected recipients for play rewards generated by this NFT.
   * @return recipients The addresses to which rewards should be paid and their relative shares.
   * @dev If the record is found, this will return 1 or more recipients, and the shares defined will sum to exactly 100%
   * in basis points. If the record is not found, this will revert instead.
   */
  function getPlayRewardShares(uint256 recordId) external view returns (Recipient[] memory recipients);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../shared/SharedTypes.sol";

/**
 * @title APIs for play rewards generated by this ERC-721 NFT.
 * @author batu-inal & HardlyDifficult
 */
interface IPlayRewardShare721 {
  /**
   * @notice Emitted when play rewards are paid through this contract.
   * @param tokenId The tokenId of the NFT for which rewards were paid.
   * @param to The address to which the rewards were paid.
   * There may be multiple payments for a single payment transaction, one for each recipient.
   * @param operator The account which initiated and provided the funds for this payment.
   * @param role The role of the recipient in terms of why they are receiving a share of payments.
   * @param paymentToken The token used to pay the rewards, or address(0) if ETH was distributed.
   * @param tokenAmount The amount of `paymentToken` sent to the `to` address.
   */
  event PlayRewardPaid(
    uint256 indexed tokenId,
    address indexed to,
    address indexed operator,
    RecipientRole role,
    address paymentToken,
    uint256 tokenAmount
  );

  /**
   * @notice Emitted when additional recipients are provided for an NFT's play rewards.
   * @param tokenId The tokenId of the NFT for which reward recipients were set.
   * @param recipients The addresses to which rewards should be paid and their relative shares.
   */
  event PlayRewardRecipientsSet(uint256 indexed tokenId, Recipient[] recipients);

  /**
   * @notice Pays play rewards generated by this NFT to the expected recipients.
   * @param tokenId The tokenId of the NFT for which rewards were earned.
   * @param recipients The address and relative share each recipient should receive.
   * @param paymentToken The token to use to pay the rewards, or address(0) if ETH will be distributed.
   * @param tokenAmount The amount of `paymentToken` to distribute to the recipients.
   * @dev If an ERC-20 token is used for payment, the `msg.sender` should first grant approval to this contract.
   */
  function payPlayRewards(
    uint256 tokenId,
    Recipient[] calldata recipients,
    address paymentToken,
    uint256 tokenAmount
  ) external payable;

  /**
   * @notice Sets additional recipients for play rewards generated by this NFT.
   * @dev This is only callable while rented, by the operator which created the rental.
   * @param tokenId The tokenId of the NFT for which reward recipients should be set.
   * @param recipients Additional recipients and their share of play rewards to receive.
   * The user/player of the NFT will automatically be added as a recipient, receiving the remaining share - the sum
   * provided for the additional recipients must be less than 100%.
   */
  function setPlayRewardShareRecipients(uint256 tokenId, Recipient[] calldata recipients) external;

  /**
   * @notice Gets the expected recipients for play rewards generated by this NFT.
   * @param tokenId The tokenId of the NFT to get recipients for.s
   * @return recipients The addresses to which rewards should be paid and their relative shares.
   * @dev This will return 1 or more recipients, and the shares defined will sum to exactly 100% in basis points.
   */
  function getPlayRewardShares(uint256 tokenId) external view returns (Recipient[] memory recipients);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev From github.com/OpenZeppelin/openzeppelin-contracts/blob/dc4869e
 *           /contracts/utils/introspection/ERC165Checker.sol#L107
 * TODO: Remove once OZ releases this function.
 */
library SupportsInterfaceUnchecked {
  /**
   * @notice Query if a contract implements an interface, does not check ERC165 support
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return true if the contract at account indicates support of the interface with
   * identifier interfaceId, false otherwise
   * @dev Assumes that account contains a contract that supports ERC165, otherwise
   * the behavior of this method is undefined. This precondition can be checked
   * with {supportsERC165}.
   * Interface identification is specified in ERC-165.
   */
  function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
    // prepare call
    bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

    // perform static call
    bool success;
    uint256 returnSize;
    uint256 returnValue;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
      returnSize := returndatasize()
      returnValue := mload(0x00)
    }

    return success && returnSize >= 0x20 && returnValue > 0;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../WrappedNFTs/interfaces/IERC4907.sol";
import "../WrappedNFTs/interfaces/IERC5006.sol";

import "../shared/SharedTypes.sol";

import "../libraries/SupportsInterfaceUnchecked.sol";

/**
 * @author batu-inal & HardlyDifficult
 */
abstract contract NFTTypes {
  using SupportsInterfaceUnchecked for address;

  modifier onlyERC721(address nftContract, bool requireLending) {
    require(
      nftContract.supportsERC165InterfaceUnchecked(type(IERC721).interfaceId),
      "NFTTypes: NFT must support ERC721"
    );
    if (requireLending) {
      // Check required interfaces to list on Stash Market.
      require(
        nftContract.supportsERC165InterfaceUnchecked(type(IERC4907).interfaceId),
        "NFTTypes: NFT must support ERC4907"
      );
    }
    _;
  }

  modifier onlyERC1155(address nftContract, bool requireLending) {
    require(
      nftContract.supportsERC165InterfaceUnchecked(type(IERC1155).interfaceId),
      "NFTTypes: NFT must support ERC1155"
    );

    if (requireLending) {
      // Check required interfaces to list on Stash Market.
      require(
        nftContract.supportsERC165InterfaceUnchecked(type(IERC5006).interfaceId),
        "NFTTypes: NFT must support ERC5006"
      );
    }

    _;
  }

  // TODO remove this once the market migrates
  function _checkNftType(address nftContract, bool requireLending) internal view returns (NFTType nftType) {
    if (nftContract.supportsERC165InterfaceUnchecked(type(IERC721).interfaceId)) {
      if (requireLending) {
        // Check required interfaces to list on Stash Market.
        require(
          nftContract.supportsERC165InterfaceUnchecked(type(IERC4907).interfaceId),
          "NFTTypes: NFT must support ERC4907"
        );
      }

      nftType = NFTType.ERC721;
    } else {
      require(
        nftContract.supportsERC165InterfaceUnchecked(type(IERC1155).interfaceId),
        "NFTTypes: NFT must support ERC721 or ERC1155"
      );

      if (requireLending) {
        // Check required interfaces to list on Stash Market.
        require(
          nftContract.supportsERC165InterfaceUnchecked(type(IERC5006).interfaceId),
          "NFTTypes: NFT must support ERC5006"
        );
      }

      nftType = NFTType.ERC1155;
    }
  }

  /**
   * @notice Checks whether a contract is rentable on the Stash Market.
   * @param nftContract The address of the checked contract.
   * @return isCompatible True if the NFT supports the required NFT & lending interfaces.
   */
  function _isCompatibleForRent(address nftContract) internal view returns (bool isCompatible) {
    isCompatible =
      (nftContract.supportsERC165InterfaceUnchecked(type(IERC721).interfaceId) &&
        nftContract.supportsERC165InterfaceUnchecked(type(IERC4907).interfaceId)) ||
      (nftContract.supportsERC165InterfaceUnchecked(type(IERC1155).interfaceId) &&
        nftContract.supportsERC165InterfaceUnchecked(type(IERC5006).interfaceId));
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/Market/StashMarket.sol";

contract $StashMarket is StashMarket {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_setRentalTerms_Returned(uint256 arg0);

    event $_getNextAndIncrementTermsId_Returned(uint256 arg0);

    event $_payFees_Returned(uint256 arg0);

    constructor(address payable _weth, address payable _treasury, uint16 _feeInBasisPoints) StashMarket(_weth, _treasury, _feeInBasisPoints) {}

    function $_acquireOwnership(NFTType nftType,address nftContract,uint256 tokenId,uint64 amount,address seller,uint256 recordId1155) external {
        return super._acquireOwnership(nftType,nftContract,tokenId,amount,seller,recordId1155);
    }

    function $_buildRentalRecipients(address payable seller,uint16 lenderRevShareBasisPoints) external view returns (Recipient[] memory) {
        return super._buildRentalRecipients(seller,lenderRevShareBasisPoints);
    }

    function $_lend(NFTType nftType,address nftContract,uint256 tokenId,uint64 amount,address seller,uint64 expiry,uint256 termsId,Recipient[] calldata recipients) external {
        return super._lend(nftType,nftContract,tokenId,amount,seller,expiry,termsId,recipients);
    }

    function $_deleteRentalTerms(uint256 termsId) external {
        return super._deleteRentalTerms(termsId);
    }

    function $_setRecordId(uint256 termsId,uint256 recordId) external {
        return super._setRecordId(termsId,recordId);
    }

    function $_setRentalTerms(address nftContract,uint256 tokenId,NFTType nftType,uint64 amount,uint64 expiry,uint256 pricePerDay,uint256 lenderRevShareBasisPoints,uint256 buyPrice,address paymentToken,uint16 maxRentalDays) external returns (uint256) {
        (uint256 ret0) = super._setRentalTerms(nftContract,tokenId,nftType,amount,expiry,pricePerDay,lenderRevShareBasisPoints,buyPrice,paymentToken,maxRentalDays);
        emit $_setRentalTerms_Returned(ret0);
        return (ret0);
    }

    function $_getNextAndIncrementTermsId() external returns (uint256) {
        (uint256 ret0) = super._getNextAndIncrementTermsId();
        emit $_getNextAndIncrementTermsId_Returned(ret0);
        return (ret0);
    }

    function $_payFees(address paymentToken,uint256 totalTransactionAmount) external returns (uint256) {
        (uint256 ret0) = super._payFees(paymentToken,totalTransactionAmount);
        emit $_payFees_Returned(ret0);
        return (ret0);
    }

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    function $_checkNftType(address nftContract,bool requireLending) external view returns (NFTType) {
        return super._checkNftType(nftContract,requireLending);
    }

    function $_isCompatibleForRent(address nftContract) external view returns (bool) {
        return super._isCompatibleForRent(nftContract);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketBuy.sol";

contract $StashMarketBuy is StashMarketBuy {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_setRentalTerms_Returned(uint256 arg0);

    event $_getNextAndIncrementTermsId_Returned(uint256 arg0);

    event $_payFees_Returned(uint256 arg0);

    constructor(address payable _weth, address payable _treasury, uint16 _feeInBasisPoints) TokenTransfers(_weth) StashMarketFees(_treasury, _feeInBasisPoints) {}

    function $_acquireOwnership(NFTType nftType,address nftContract,uint256 tokenId,uint64 amount,address seller,uint256 recordId1155) external {
        return super._acquireOwnership(nftType,nftContract,tokenId,amount,seller,recordId1155);
    }

    function $_deleteRentalTerms(uint256 termsId) external {
        return super._deleteRentalTerms(termsId);
    }

    function $_setRecordId(uint256 termsId,uint256 recordId) external {
        return super._setRecordId(termsId,recordId);
    }

    function $_setRentalTerms(address nftContract,uint256 tokenId,NFTType nftType,uint64 amount,uint64 expiry,uint256 pricePerDay,uint256 lenderRevShareBasisPoints,uint256 buyPrice,address paymentToken,uint16 maxRentalDays) external returns (uint256) {
        (uint256 ret0) = super._setRentalTerms(nftContract,tokenId,nftType,amount,expiry,pricePerDay,lenderRevShareBasisPoints,buyPrice,paymentToken,maxRentalDays);
        emit $_setRentalTerms_Returned(ret0);
        return (ret0);
    }

    function $_getNextAndIncrementTermsId() external returns (uint256) {
        (uint256 ret0) = super._getNextAndIncrementTermsId();
        emit $_getNextAndIncrementTermsId_Returned(ret0);
        return (ret0);
    }

    function $_payFees(address paymentToken,uint256 totalTransactionAmount) external returns (uint256) {
        (uint256 ret0) = super._payFees(paymentToken,totalTransactionAmount);
        emit $_payFees_Returned(ret0);
        return (ret0);
    }

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketCore.sol";

contract $StashMarketCore is StashMarketCore {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketFees.sol";

contract $StashMarketFees is StashMarketFees {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_payFees_Returned(uint256 arg0);

    constructor(address payable _weth, address payable _treasury, uint16 _feeInBasisPoints) TokenTransfers(_weth) StashMarketFees(_treasury, _feeInBasisPoints) {}

    function $_payFees(address paymentToken,uint256 totalTransactionAmount) external returns (uint256) {
        (uint256 ret0) = super._payFees(paymentToken,totalTransactionAmount);
        emit $_payFees_Returned(ret0);
        return (ret0);
    }

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketLender.sol";

contract $StashMarketLender is StashMarketLender {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_setRentalTerms_Returned(uint256 arg0);

    event $_getNextAndIncrementTermsId_Returned(uint256 arg0);

    event $_payFees_Returned(uint256 arg0);

    constructor(address payable _weth, address payable _treasury, uint16 _feeInBasisPoints) TokenTransfers(_weth) StashMarketFees(_treasury, _feeInBasisPoints) {}

    function $_deleteRentalTerms(uint256 termsId) external {
        return super._deleteRentalTerms(termsId);
    }

    function $_setRecordId(uint256 termsId,uint256 recordId) external {
        return super._setRecordId(termsId,recordId);
    }

    function $_setRentalTerms(address nftContract,uint256 tokenId,NFTType nftType,uint64 amount,uint64 expiry,uint256 pricePerDay,uint256 lenderRevShareBasisPoints,uint256 buyPrice,address paymentToken,uint16 maxRentalDays) external returns (uint256) {
        (uint256 ret0) = super._setRentalTerms(nftContract,tokenId,nftType,amount,expiry,pricePerDay,lenderRevShareBasisPoints,buyPrice,paymentToken,maxRentalDays);
        emit $_setRentalTerms_Returned(ret0);
        return (ret0);
    }

    function $_getNextAndIncrementTermsId() external returns (uint256) {
        (uint256 ret0) = super._getNextAndIncrementTermsId();
        emit $_getNextAndIncrementTermsId_Returned(ret0);
        return (ret0);
    }

    function $_payFees(address paymentToken,uint256 totalTransactionAmount) external returns (uint256) {
        (uint256 ret0) = super._payFees(paymentToken,totalTransactionAmount);
        emit $_payFees_Returned(ret0);
        return (ret0);
    }

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    function $_checkNftType(address nftContract,bool requireLending) external view returns (NFTType) {
        return super._checkNftType(nftContract,requireLending);
    }

    function $_isCompatibleForRent(address nftContract) external view returns (bool) {
        return super._isCompatibleForRent(nftContract);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketRenter.sol";

contract $StashMarketRenter is StashMarketRenter {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_setRentalTerms_Returned(uint256 arg0);

    event $_getNextAndIncrementTermsId_Returned(uint256 arg0);

    event $_payFees_Returned(uint256 arg0);

    constructor(address payable _weth, address payable _treasury, uint16 _feeInBasisPoints) TokenTransfers(_weth) StashMarketFees(_treasury, _feeInBasisPoints) {}

    function $_buildRentalRecipients(address payable seller,uint16 lenderRevShareBasisPoints) external view returns (Recipient[] memory) {
        return super._buildRentalRecipients(seller,lenderRevShareBasisPoints);
    }

    function $_lend(NFTType nftType,address nftContract,uint256 tokenId,uint64 amount,address seller,uint64 expiry,uint256 termsId,Recipient[] calldata recipients) external {
        return super._lend(nftType,nftContract,tokenId,amount,seller,expiry,termsId,recipients);
    }

    function $_deleteRentalTerms(uint256 termsId) external {
        return super._deleteRentalTerms(termsId);
    }

    function $_setRecordId(uint256 termsId,uint256 recordId) external {
        return super._setRecordId(termsId,recordId);
    }

    function $_setRentalTerms(address nftContract,uint256 tokenId,NFTType nftType,uint64 amount,uint64 expiry,uint256 pricePerDay,uint256 lenderRevShareBasisPoints,uint256 buyPrice,address paymentToken,uint16 maxRentalDays) external returns (uint256) {
        (uint256 ret0) = super._setRentalTerms(nftContract,tokenId,nftType,amount,expiry,pricePerDay,lenderRevShareBasisPoints,buyPrice,paymentToken,maxRentalDays);
        emit $_setRentalTerms_Returned(ret0);
        return (ret0);
    }

    function $_getNextAndIncrementTermsId() external returns (uint256) {
        (uint256 ret0) = super._getNextAndIncrementTermsId();
        emit $_getNextAndIncrementTermsId_Returned(ret0);
        return (ret0);
    }

    function $_payFees(address paymentToken,uint256 totalTransactionAmount) external returns (uint256) {
        (uint256 ret0) = super._payFees(paymentToken,totalTransactionAmount);
        emit $_payFees_Returned(ret0);
        return (ret0);
    }

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/Market/mixins/StashMarketTerms.sol";

contract $StashMarketTerms is StashMarketTerms {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    event $_setRentalTerms_Returned(uint256 arg0);

    event $_getNextAndIncrementTermsId_Returned(uint256 arg0);

    constructor() {}

    function $_deleteRentalTerms(uint256 termsId) external {
        return super._deleteRentalTerms(termsId);
    }

    function $_setRecordId(uint256 termsId,uint256 recordId) external {
        return super._setRecordId(termsId,recordId);
    }

    function $_setRentalTerms(address nftContract,uint256 tokenId,NFTType nftType,uint64 amount,uint64 expiry,uint256 pricePerDay,uint256 lenderRevShareBasisPoints,uint256 buyPrice,address paymentToken,uint16 maxRentalDays) external returns (uint256) {
        (uint256 ret0) = super._setRentalTerms(nftContract,tokenId,nftType,amount,expiry,pricePerDay,lenderRevShareBasisPoints,buyPrice,paymentToken,maxRentalDays);
        emit $_setRentalTerms_Returned(ret0);
        return (ret0);
    }

    function $_getNextAndIncrementTermsId() external returns (uint256) {
        (uint256 ret0) = super._getNextAndIncrementTermsId();
        emit $_getNextAndIncrementTermsId_Returned(ret0);
        return (ret0);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/WrappedNFTs/interfaces/IERC4907.sol";

abstract contract $IERC4907 is IERC4907 {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/WrappedNFTs/interfaces/IERC5006.sol";

abstract contract $IERC5006 is IERC5006 {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/WrappedNFTs/interfaces/IPlayRewardShare1155.sol";

abstract contract $IPlayRewardShare1155 is IPlayRewardShare1155 {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../../contracts/WrappedNFTs/interfaces/IPlayRewardShare721.sol";

abstract contract $IPlayRewardShare721 is IPlayRewardShare721 {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/interfaces/IWeth.sol";

abstract contract $IWeth is IWeth {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/libraries/SupportsInterfaceUnchecked.sol";

contract $SupportsInterfaceUnchecked {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $supportsERC165InterfaceUnchecked(address account,bytes4 interfaceId) external view returns (bool) {
        return SupportsInterfaceUnchecked.supportsERC165InterfaceUnchecked(account,interfaceId);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/libraries/Time.sol";

contract $Time {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $hasExpired(uint64 expiry) external view returns (bool) {
        return Time.hasExpired(expiry);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/shared/Constants.sol";

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/shared/NFTTypes.sol";

contract $NFTTypes is NFTTypes {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $_checkNftType(address nftContract,bool requireLending) external view returns (NFTType) {
        return super._checkNftType(nftContract,requireLending);
    }

    function $_isCompatibleForRent(address nftContract) external view returns (bool) {
        return super._isCompatibleForRent(nftContract);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/shared/SharedTypes.sol";

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/shared/TokenTransfers.sol";

contract $TokenTransfers is TokenTransfers {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor(address payable _weth) TokenTransfers(_weth) {}

    function $_transferFunds(address to,address paymentToken,uint256 amount) external {
        return super._transferFunds(to,paymentToken,amount);
    }

    receive() external payable {}
}
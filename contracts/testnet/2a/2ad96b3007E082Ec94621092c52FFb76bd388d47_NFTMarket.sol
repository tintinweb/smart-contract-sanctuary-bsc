//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IERC721P.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketEvents.sol";
import "./Verification.sol";
import "./ILazymint.sol";
import "./IVaultRewards.sol";
import "./IControl.sol";

/// @title A contract for selling single and batched NFTs
/// @notice This contract can be used for auctioning any NFTs, and accepts any ERC20 token as payment
contract NFTMarket is MarketEvents, verification, AccessControl {

     ///@dev developer role created
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");

    struct Localvars {
        string _uri;
        address _nftContractAddress;
        uint256 _tokenId;
        address _erc20Token;
        uint256 _buyNowPrice;
        address[] _feeRecipients;
        uint32[] _feePercentages;
        address _nftSeller;
        uint256 _amount;
        address _nftHighestBidder;
        bool lazymint;
    }

    ///@notice Each sell is unique to each NFT (contract + id pairing).
    ///@param ERC20Token The seller can specify an ERC20 token that can be used to bid or purchase the NFT.
    struct Sells {
        uint256 buyNowPrice;
        address nftHighestBidder;
        address nftSeller;
        address ERC20Token;
        address[] feeRecipients;
        uint32[] feePercentages;
    }
     ///@notice Map each sell with the token ID
    mapping(address => mapping(uint256 => Sells)) public nftContractAuctions;
    ///@notice If transfer fail save to withdraw later
    mapping(address => uint256) public failedTransferCredits;

    ///@notice Default values market fee
    address payable public addressmarketfee;
    uint256 public feeMarket = 75; //Equal 0.75%
    uint256 public feeBuyers = 75; //Equal 0.75%
    uint256 private feeRewards = 5000; //Equals 50%
    uint256 private feePanoram = 5000; //Equals 50%
    address public feeVaultAddress;
    address payable public panoramWallet;
    address public control;

    /*///////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier isAuctionNotStartedByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        if(
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller ==
                msg.sender){
            revert ("Initiated by the owner");
        }

        if (
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
            address(0)
        ) {
            if(
                msg.sender != IERC721P(_nftContractAddress).ownerOf(_tokenId)){
                 revert ("Sender doesn't own NFT");
            }
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                              END MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address _addressmarketfee, address _feeVault, address _panoramWallet, address _control) {
        addressmarketfee = payable(_addressmarketfee);
        feeVaultAddress = payable(_feeVault);
        panoramWallet = payable(_panoramWallet);
        control = _control;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEV_ROLE, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                    AUCTION/SELL CHECK FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    ///@dev If the buy now price is set by the seller, check that the highest bid meets that price.
    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId, uint256 amount)
        internal
        view
        returns (bool)
    {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        return
            /*buyNowPrice > 0 &&*/ amount >= buyNowPrice;
    }

    ///@dev Payment is accepted in the following scenarios:
    ///@dev (1) Auction already created - can accept ETH or Specified Token
    ///@dev  --------> Cannot bid with ETH & an ERC20 Token together in any circumstance<------
    ///@dev (2) Auction not created - only ETH accepted (cannot early bid with an ERC20 Token
    ///@dev (3) Cannot make a zero bid (no ETH or Token amount)
    function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _ERC20Token,
        uint256 _tokenAmount
    ) internal view returns (bool _status) {
            address ERC20Address = nftContractAuctions[
                _nftContractAddress][_tokenId].ERC20Token;
            if (ERC20Address != address(0)) {
                return false;
            }else if(msg.value == 0 &&
                    ERC20Address == _ERC20Token &&
                    _tokenAmount > 0){
                return true;
            }
    }

    /*///////////////////////////////////////////////////////////////
                                     END
                            AUCTION CHECK FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                      TRANSFER NFTS TO CONTRACT
    //////////////////////////////////////////////////////////////*/

    function _transferNftToMarketContract(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {
        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if (IERC721P(_nftContractAddress).ownerOf(_tokenId) == _nftSeller) {
            IERC721P(_nftContractAddress).transferFrom(
                _nftSeller,
                address(this),
                _tokenId
            );
            if(
                IERC721P(_nftContractAddress).ownerOf(_tokenId) != address(this)){
                revert ("nft transfer failed");
            }
        } else {
            if(
                IERC721P(_nftContractAddress).ownerOf(_tokenId) != address(this)){
                revert ("Seller doesn't own NFT");
           }
        }
    }

    /*///////////////////////////////////////////////////////////////
                                END
                      TRANSFER NFTS TO CONTRACT
    //////////////////////////////////////////////////////////////*/


    /*///////////////////////////////////////////////////////////////
                              SALES
    //////////////////////////////////////////////////////////////*/

    ///@notice Allows for a standard sale mechanism.
    ///@dev For sale the min price must be 0
    ///@dev _isABidMade check if buyNowPrice is meet and conclude sale, otherwise reverse the early bid
    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address _nftSeller,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_buyNowPrice)
    {
        Localvars memory vars;
       
        vars._nftContractAddress = _nftContractAddress;
        vars._tokenId = _tokenId;
        vars._erc20Token = _erc20Token;
        vars._buyNowPrice = _buyNowPrice;
        vars._feeRecipients = _feeRecipients;
        vars._feePercentages = _feePercentages;
        vars._nftSeller = _nftSeller;

        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .nftSeller = vars._nftSeller;
        if (vars._erc20Token != address(0)) {
            nftContractAuctions[vars._nftContractAddress][vars._tokenId]
                .ERC20Token = vars._erc20Token;
        }
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .feeRecipients = vars._feeRecipients;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .feePercentages = vars._feePercentages;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .buyNowPrice = vars._buyNowPrice;

        vars._uri = metadata(vars._nftContractAddress, vars._tokenId);

        _transferNftToMarketContract(vars._nftContractAddress, vars._tokenId);

        emit SaleCreated(
            vars._nftContractAddress,
            vars._tokenId,
            vars._nftSeller,
            vars._erc20Token,
           vars. _buyNowPrice,
           vars. _feeRecipients,
            vars._feePercentages
        );
        
        
        
    }

    /*///////////////////////////////////////////////////////////////
                              END  SALES
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              BID FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    ///@notice Make bids with ETH or an ERC20 Token specified by the NFT seller.
    ///@notice Additionally, a buyer can pay the asking price to conclude a sale of an NFT.
    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _tokenAmount,
        uint256 _feeAmount
    ) external payable {
        uint256 buyAmount;
        Localvars memory vars;
        vars._nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if(msg.sender == vars._nftSeller){
            revert ("Owner cannot buy your NFT");
        }
        if(
            !_isPaymentAccepted(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _tokenAmount
            )){
            revert("Buy to be in specified ERC20/BNB");
        }
        
        if(_tokenAmount != 0){
            buyAmount = _tokenAmount - _feeAmount;
            vars._amount = buyAmount;
        }else{
            buyAmount = msg.value - _feeAmount;
            vars._amount = buyAmount;
        }
        ///@dev Transfer buy fees to the vault
        IVaultRewards(feeVaultAddress).deposit(_feeAmount, _erc20Token);
       // _updateSell(_nftContractAddress, _tokenId, vars._amount);
       if (_isBuyNowPriceMet(_nftContractAddress, _tokenId,vars._amount)) {
            _transferNftAndPaySeller(_nftContractAddress, _tokenId, msg.sender, vars._amount);
       }else{
            revert("amount less than buy now");
       }
        
        emit BidMade(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            msg.value,
            _erc20Token,
            _tokenAmount
        );
    }

    /*///////////////////////////////////////////////////////////////
                        END BID FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                           RESET FUNCTIONS
   //////////////////////////////////////////////////////////////*/

    ///@notice Reset all auction related parameters for an NFT.
    ///@notice This effectively removes an NFT as an item up for auction
    function _resetSell(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        
        nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
    }
  

    /*///////////////////////////////////////////////////////////////
                        END RESET FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                    TRANSFER NFT, PAY SELLER & MARKET
    //////////////////////////////////////////////////////////////*/
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address buyer,
        uint256 amount
    ) internal {
        Localvars memory vars;
        vars._nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        vars._nftHighestBidder = buyer;

        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            vars._nftSeller,
            amount
        );

        IERC721P(_nftContractAddress).transferFrom(
                address(this),
                vars._nftHighestBidder,
                _tokenId
            );
        IControl(control).addRegistry(_nftContractAddress, _tokenId, vars._nftHighestBidder, uint32(block.timestamp));
        _resetSell(_nftContractAddress, _tokenId);
        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            vars._nftSeller,
            vars._nftHighestBidder
        );
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _amount
    ) internal {
        uint256 feesPaid = 0;
        uint256 minusSellFee = _getPortionOfBid(_amount, feeMarket);

        feesPaid = _payoutroyalties(_nftContractAddress, _tokenId, _amount);

        uint256 subtotal = minusSellFee + feesPaid;

        uint256 reward = _amount - subtotal;

        _payout(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            reward
        );
        ///@dev Transfer sell fees to the vault
        sendpayment(_nftContractAddress, _tokenId, minusSellFee);
    }

    function sendpayment(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 minusfee
    ) internal {
        uint256 amount = minusfee;
        minusfee = 0;
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;

        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transfer(addressmarketfee, amount);
        } else {
            (bool success, ) = payable(addressmarketfee).call{value: amount}(
                ""
            );
            if (!success) {
                failedTransferCredits[addressmarketfee] =
                    failedTransferCredits[addressmarketfee] +
                    amount;
            }
        }
    }

    function _payoutroyalties(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 subtotal
    ) internal returns (uint256) {
        uint256 feesPaid = 0;
        uint256 length = nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients
            .length;
        for (uint256 i = 0; i < length; i++) {
            uint256 fee = _getPortionOfBid(
                subtotal,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feePercentages[i]
            );
            feesPaid = feesPaid + fee;
            _payout(
                _nftContractAddress,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feeRecipients[i],
                fee
            );
        }
        return feesPaid;
    }

    ///@dev if the call failed, update their credit balance so they the seller can pull it later
    function _payout(
        address _nftContractAddress,
        uint256 _tokenId,
        address _recipient,
        uint256 _amount
    ) internal {
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;

        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{value: _amount}("");
            if (!success) {
                failedTransferCredits[_recipient] =
                    failedTransferCredits[_recipient] +
                    _amount;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                      END TRANSFER NFT, PAY SELLER & MARKET
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                         WITHDRAW
    //////////////////////////////////////////////////////////////*/
    ///@dev Only the owner of the NFT can prematurely close the sale or auction.
    function withdrawSell(address _nftContractAddress, uint256 _tokenId)
        external
    {
        if(nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
                msg.sender){
           revert("cannot cancel an auction");
      }
        if (IERC721P(_nftContractAddress).ownerOf(_tokenId) == address(this)) {
                IERC721P(_nftContractAddress).transferFrom(
                    address(this),
                    nftContractAuctions[_nftContractAddress][_tokenId]
                        .nftSeller,
                    _tokenId
                );
            }
            _resetSell(_nftContractAddress, _tokenId);

        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                         END  & WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          UPDATE SELLS
    //////////////////////////////////////////////////////////////*/
    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newBuyNowPrice
    ) external priceGreaterThanZero(_newBuyNowPrice) {
        if(
            msg.sender !=
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller){
            revert ("Only nft seller");
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _newBuyNowPrice;
        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);
    }

    ///@notice If the transfer of a bid has failed, allow the recipient to reclaim their amount later.
    function withdrawAllFailedCredits() external {
        uint256 amount = failedTransferCredits[msg.sender];

        if(amount == 0){
            revert ("no credits to withdraw");
        }

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{value: amount}("");
        if(!successfulWithdraw){
            revert ("withdraw failed");
        }
    }

    /*///////////////////////////////////////////////////////////////
                        END UPDATE SELLS
    //////////////////////////////////////////////////////////////*/


     /*///////////////////////////////////////////////////////////////
                        UPDATE FEES
    //////////////////////////////////////////////////////////////*/
    function updateFeeMarket(uint256 _newfeeMarket) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            feeMarket = _newfeeMarket;
    }

     function updateFeeBuyers(uint256 _newfeebuyers) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            feeBuyers = _newfeebuyers;
    }

    function updateFeeRewards(uint256 _newfeeRewards) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            feeRewards = _newfeeRewards;
    }

    function updateFeePanoram(uint256 _newfeePanoram) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            feePanoram = _newfeePanoram;
    }

    function updateVaultRewards(address _newVaultRewards) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            feeVaultAddress = _newVaultRewards;
    }

    
     /*///////////////////////////////////////////////////////////////
                        END UPDATE FEES
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        MINTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function minting(address _collection, address _owner, uint256 _value, uint256 _fee, address _token) public {
        (uint256 pan, uint256 rewards) = calcFees(_fee);
        uint256 sell = _value - _fee;
        IVaultRewards(feeVaultAddress).deposit(rewards, _token);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, pan);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, sell);
        uint256 _nftId = ILazyNFT(_collection).redeem(_owner, sell);
        IControl(control).addCounter();
        IControl(control).addRegistry(_collection, _nftId, _owner, uint32(block.timestamp));
    }

    function batchmint(address _collection, address _owner, uint256 _amount ,uint256 _value, uint256 _fee, address _token) public {
        (uint256 pan, uint256 rewards) = calcFees(_fee);
        uint256 sell = _value - _fee;
        IVaultRewards(feeVaultAddress).deposit(rewards, _token);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, pan);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, sell);
        for(uint256 i=1; i <= _amount;){
            uint256 _nftId = ILazyNFT(_collection).redeem(_owner, sell);
            IControl(control).addCounter();
            IControl(control).addRegistry(_collection, _nftId, _owner, uint32(block.timestamp));
            unchecked {
             ++i;
            }
        }
    }

    function presaleMint(address _collection, address _owner, uint256 _value, uint256 _fee, address _token) public {
        (uint256 pan, uint256 rewards) = calcFees(_fee);
        uint256 sell = _value - _fee;
        IVaultRewards(feeVaultAddress).deposit(rewards, _token);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, pan);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, sell);
        uint256 _nftId = ILazyNFT(_collection).preSale(_owner, sell);
        IControl(control).addCounter();
        IControl(control).addRegistry(_collection, _nftId, _owner, uint32(block.timestamp));
    }

    function presaleMintbatch(address _collection, address _owner, uint256 _amount ,uint256 _value, uint256 _fee, address _token) public {
        (uint256 pan, uint256 rewards) = calcFees(_fee);
        uint256 sell = _value - _fee;
        IVaultRewards(feeVaultAddress).deposit(rewards, _token);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, pan);
        IERC20(_token).transferFrom(msg.sender, panoramWallet, sell);
        for(uint256 i=1; i <= _amount;){
            uint256 _nftId = ILazyNFT(_collection).preSale(_owner, sell);
            IControl(control).addCounter();
            IControl(control).addRegistry(_collection, _nftId, _owner, uint32(block.timestamp));
            unchecked {
             ++i;
            }
        }
    }

    function calcFees(uint256 _fee) internal view returns(uint256 panoram, uint256 rewards){
        rewards = _getPortionOfBid(_fee, feeRewards);
        panoram = _getPortionOfBid(_fee, feePanoram);
        return (panoram,rewards);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC721P is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);
 
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function holdInfo(uint256 tokenId) external view returns (uint32);

    function mintInfo(address _owner) external view  returns (uint32);

    function walletOfOwner(address _owner) external view returns (uint256[] memory, uint256 _length);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract MarketEvents {
    /*///////////////////////////////////////////////////////////////
                              EVENTS            
    //////////////////////////////////////////////////////////////*/

    event SaleCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint256 buyNowPrice,
        address[] feeRecipients,
        uint32[] feePercentages
    );

    event BidMade(
        address nftContractAddress,
        uint256 tokenId,
        address bidder,
        uint256 ethAmount,
        address erc20Token,
        uint256 tokenAmount
    );


    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address nftHighestBidder
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newBuyNowPrice
    );

    event NFTTransferred(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder
    );

    /*///////////////////////////////////////////////////////////////
                              END EVENTS            
    //////////////////////////////////////////////////////////////*/
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

abstract contract verification {
    ///@dev Returns the percentage of the total bid (used to calculate fee payments)
    function _getPortionOfBid(uint256 _totalBid, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        return (_totalBid * (_percentage)) / 10000;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        if(_price <= 0) {
            revert ("Price cannot be 0");
        }
        _;
    }

    modifier isFeePercentagesLessThanMaximum(uint32[] memory _feePercentages) {
        uint32 totalPercent;
        for (uint256 i = 0; i < _feePercentages.length; i++) {
            totalPercent = totalPercent + _feePercentages[i];
        }
        require(totalPercent <= 10000, "Fee percentages exceed maximum");
        _;
    }

    function metadata(address _nftcontract, uint256 _nftid)
        internal
        view
        returns (
            //bool _mint
            string memory
        )
    {
        return IERC721Metadata(_nftcontract).tokenURI(_nftid);
     
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILazyNFT {
    function redeem(
        address _redeem,
        uint256 _amount
    ) external returns (uint256);

    function preSale(
        address _redeem,
        uint256 _amount
    ) external returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory base);

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory, uint256 _length);

    function totalSupply() external view returns (uint256);

    function maxSupply() external view returns (uint256);
     
    function getPrice() external view returns (uint256);
    
    function getPresale() external view returns (uint256);

    function getPresaleStatus() external view returns (bool);

    function nftcost() external view returns (uint256 _price);
}

// SPDX-License-Identifier: MIT
pragma solidity >0.8.10;

interface IVaultRewards {
    function deposit(uint256 _amount,  address _token) external;

    function withdraw(uint256 amount, address _token) external;

    function setStrategyContract(address) external;

    function setmultisig(address) external;

    function withdrawAll() external;

    function seeDaily() external view returns (uint256 tempRewards);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IControl {

   function getNFTInfo(address _collection, uint256 _id)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint32
        );

    function addRegistry(address _collection, uint256 _nftId, address _wallet,uint32 _timestamp) external;

    function updateRegistry(address _collection, uint256 _nftId, address _wallet, uint32 _timestamp) external;

    function removeRegistry(address _collection, uint256 _nftId) external;

    function addCounter() external;

    function seeCounter() external view returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
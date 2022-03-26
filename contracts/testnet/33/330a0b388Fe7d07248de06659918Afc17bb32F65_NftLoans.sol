/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT
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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

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
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract NftLoans {
    using SafeMath for uint256;

    IERC721 nftMarketplace;

    uint256 public purchasingIdNumber;

    struct Borrow {
        address owner;
        uint256 bundleValue;
        uint256 amount;
        uint256 ltvRatio;
        uint256 totalRepaymentAmount;
        uint256 amountPerInstallment;
        uint256 numberOfInstallments;
        uint256 annualPercentageRate;
        uint256 installmentPeriod;
        string loanRisk;
    }

    struct LoanProvider {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint256 timeGetLoan;
        uint256 totalRepaymentTime;
        bool isAllLoanPaid;
        bool isGetLoan;
    }

    mapping(uint256 => Borrow) private userBorrowRequest;

    mapping(address => mapping(uint256 => bool)) private forLoan;
    mapping(uint256 => LoanProvider) private loanProviderDetails;
    mapping(address => bool) private isLoanProvider;

    mapping(address => uint256[]) private purchasingId;
    mapping(uint256 => uint256[]) private storedBorrowNftId;

    mapping(uint256 => mapping(uint256 => bool)) private installmentComplete;
    mapping(uint256 => bool) private isIdDealClosed;

    event Collateral(uint256, uint256[], uint256, address, uint256);
    event Loan(uint256, uint256, uint256[], address);
    event PayInstallment(uint256, address, uint256);
    event PayAllLoan(uint256, address, uint256);
    event TransferNFT(uint256, address, uint256[]);

    constructor(address _token) {
        nftMarketplace = IERC721(_token);
    }

    function createCollateral(
        uint256[] memory _tokenId,
        uint256 _bundleValue,
        uint256 _amount,
        uint256 _ltvRatio,
        uint256 _totalRepaymentAmount,
        uint256 _amountPerInstallment,
        uint256 _numberOfInstallments,
        uint256 _annualPercentageRate,
        uint256 _installmentPeriod,
        string memory _loanRisk
    ) external {
        require(_tokenId.length != 0, "empty nft array");

        //put calculation so that we can check input values match our logics

        for (uint256 i = 0; i < _tokenId.length; i++) {
            nftMarketplace.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId[i]
            );
        }

        purchasingIdNumber = purchasingIdNumber.add(1);

        storedBorrowNftId[purchasingIdNumber] = _tokenId;

        userBorrowRequest[purchasingIdNumber] = Borrow(
            msg.sender,
            _bundleValue,
            _amount,
            _ltvRatio,
            _totalRepaymentAmount,
            _amountPerInstallment,
            _numberOfInstallments,
            _annualPercentageRate,
            _installmentPeriod,
            _loanRisk
        );

        forLoan[msg.sender][purchasingIdNumber] = true;

        emit Collateral(
            purchasingIdNumber,
            _tokenId,
            _amount,
            msg.sender,
            _totalRepaymentAmount
        );
    }

    function provideLoan(uint256 _purchasingIdNumber) external payable {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        require(
            msg.value >= userBorrowRequest[_purchasingIdNumber].amount,
            "amount is less than borrow required amount"
        );
        require(
            !loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "this puchase id already get loan"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");

        loanProviderDetails[_purchasingIdNumber] = LoanProvider(
            msg.sender,
            _purchasingIdNumber,
            userBorrowRequest[_purchasingIdNumber].amount,
            0,
            0,
            false,
            false
        );

        isLoanProvider[msg.sender] = true;

        uint256 time = userBorrowRequest[_purchasingIdNumber]
            .installmentPeriod
            .mul(userBorrowRequest[_purchasingIdNumber].numberOfInstallments);
        time = (1 days * time);
        loanProviderDetails[_purchasingIdNumber].totalRepaymentTime = block
            .timestamp
            .add(time);
        loanProviderDetails[_purchasingIdNumber].timeGetLoan = block.timestamp;

        loanProviderDetails[_purchasingIdNumber].isGetLoan = true;

        _sendAmount(
            userBorrowRequest[_purchasingIdNumber].owner,
            userBorrowRequest[_purchasingIdNumber].amount
        );
    }

    function payInstallment(uint256 _purchasingIdNumber)
        external
        payable
        returns (bool)
    {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        require(
            msg.value >=
                userBorrowRequest[_purchasingIdNumber].amountPerInstallment,
            "amount less than installment amount"
        );
        require(
            loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "till now id don't get loan"
        );
        require(
            userBorrowRequest[_purchasingIdNumber].owner == msg.sender,
            "you are not loan reciever"
        );
        require(
            !loanProviderDetails[_purchasingIdNumber].isAllLoanPaid,
            "loan paid for this id"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");

        for (
            uint256 i = 0;
            i < userBorrowRequest[_purchasingIdNumber].numberOfInstallments;
            i++
        ) {
            if (!installmentComplete[_purchasingIdNumber][i]) {
                _sendAmount(
                    loanProviderDetails[_purchasingIdNumber].owner,
                    userBorrowRequest[_purchasingIdNumber].amountPerInstallment
                );
                installmentComplete[_purchasingIdNumber][i] = true;
                userBorrowRequest[_purchasingIdNumber]
                    .totalRepaymentAmount = userBorrowRequest[
                    _purchasingIdNumber
                ].totalRepaymentAmount.sub(
                        userBorrowRequest[_purchasingIdNumber]
                            .amountPerInstallment
                    );
                _installmentComplete(_purchasingIdNumber, i+1);
                return true;
            }
        }
     
        emit PayInstallment(
            _purchasingIdNumber,
            loanProviderDetails[_purchasingIdNumber].owner,
            userBorrowRequest[_purchasingIdNumber].amountPerInstallment
        );

        return true;
    }

    function payCompleteBorrowAmount(uint256 _purchasingIdNumber)
        external
        payable
    {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        require(
            msg.value >=
                userBorrowRequest[_purchasingIdNumber].totalRepaymentAmount,
            "amount less than return amount"
        );
        require(
            loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "till now id don't get loan"
        );
        require(
            !loanProviderDetails[_purchasingIdNumber].isAllLoanPaid,
            "loan paid for this id"
        );
        require(
            userBorrowRequest[_purchasingIdNumber].owner == msg.sender,
            "you are not loan reciever"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");

        _sendAmount(
            loanProviderDetails[_purchasingIdNumber].owner,
            userBorrowRequest[_purchasingIdNumber].totalRepaymentAmount
        );
        
        userBorrowRequest[_purchasingIdNumber].totalRepaymentAmount = 0;

        for (
            uint256 i = 0;
            i < userBorrowRequest[_purchasingIdNumber].numberOfInstallments;
            i++
        ) {
            installmentComplete[_purchasingIdNumber][i] = true;
        }

        loanProviderDetails[_purchasingIdNumber].isAllLoanPaid = true;

        emit PayAllLoan(
            _purchasingIdNumber,
            loanProviderDetails[_purchasingIdNumber].owner,
            userBorrowRequest[_purchasingIdNumber].totalRepaymentAmount
        );
    }

    function claimForCollateral(uint256 _purchasingIdNumber) external {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        (,bool status) = getTimeLeftForRepayment(_purchasingIdNumber);
        require(status, "this is not collateral time");
        require(
            loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "till now id don't get loan"
        );
        require(
            !loanProviderDetails[_purchasingIdNumber].isAllLoanPaid,
            "loan paid for this id"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");
        require(
            loanProviderDetails[_purchasingIdNumber].owner == msg.sender,
            "not loan provider"
        );

        for (
            uint256 i = 0;
            i < storedBorrowNftId[_purchasingIdNumber].length;
            i++
        ) {
            nftMarketplace.safeTransferFrom(
                address(this),
                loanProviderDetails[_purchasingIdNumber].owner,
                storedBorrowNftId[_purchasingIdNumber][i]
            );
        }

        isIdDealClosed[_purchasingIdNumber] = true;

        emit TransferNFT(
            _purchasingIdNumber,
            loanProviderDetails[_purchasingIdNumber].owner,
            storedBorrowNftId[_purchasingIdNumber]
        );
    }

    function claimForRepayment(uint256 _purchasingIdNumber) external {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        (, bool status) = getTimeLeftForRepayment(_purchasingIdNumber);
        require(!status, "loan did'nt paid");
        require(
            loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "till now id don't get loan"
        );
        require(
            loanProviderDetails[_purchasingIdNumber].isAllLoanPaid,
            "loan did'nt paid for this id"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");
        require(
            userBorrowRequest[_purchasingIdNumber].owner == msg.sender,
            "not borrower"
        );

        for (
            uint256 i = 0;
            i < storedBorrowNftId[_purchasingIdNumber].length;
            i++
        ) {
            nftMarketplace.safeTransferFrom(
                address(this),
                userBorrowRequest[_purchasingIdNumber].owner,
                storedBorrowNftId[_purchasingIdNumber][i]
            );
        }

        isIdDealClosed[_purchasingIdNumber] = true;

        emit TransferNFT(
            _purchasingIdNumber,
            userBorrowRequest[_purchasingIdNumber].owner,
            storedBorrowNftId[_purchasingIdNumber]
        );
    }

    function removeFromLoan(uint256 _purchasingIdNumber) external {
        require(
            purchasingIdNumber>=_purchasingIdNumber,
            "wrong purchase id"
        );
        require(
            !loanProviderDetails[_purchasingIdNumber].isGetLoan,
            "id get loan"
        );
        require(!isIdDealClosed[_purchasingIdNumber], "deal closed");
        require(
            userBorrowRequest[_purchasingIdNumber].owner == msg.sender,
            "not borrower"
        );

        for (
            uint256 i = 0;
            i < storedBorrowNftId[_purchasingIdNumber].length;
            i++
        ) {
            nftMarketplace.safeTransferFrom(
                address(this),
                userBorrowRequest[_purchasingIdNumber].owner,
                storedBorrowNftId[_purchasingIdNumber][i]
            );
        }

        isIdDealClosed[_purchasingIdNumber] = true;

        emit TransferNFT(
            _purchasingIdNumber,
            userBorrowRequest[_purchasingIdNumber].owner,
            storedBorrowNftId[_purchasingIdNumber]
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getLoanStatus(uint256 _purchasingIdNumber)
        external
        view
        returns (
            bool,
            bool,
            bool
        )
    {
        return (
            isIdDealClosed[_purchasingIdNumber],
            loanProviderDetails[_purchasingIdNumber].isAllLoanPaid,
            loanProviderDetails[_purchasingIdNumber].isGetLoan
        );
    }

    function getCollateralInfo(uint256 _purchasingIdNumber)
        external
        view
        returns (Borrow memory)
    {
        return userBorrowRequest[_purchasingIdNumber];
    }

    function getLoanProviderInfo(uint256 _purchasingIdNumber)
        external
        view
        returns (LoanProvider memory)
    {
        return loanProviderDetails[_purchasingIdNumber];
    }

    function getListOfCollateralNft(uint256 _purchasingIdNumber)
        external
        view
        returns (uint256[] memory)
    {
        return storedBorrowNftId[_purchasingIdNumber];
    }

    function getInstallmentDetails(
        uint256 _purchasingIdNumber,
        uint256 _installmentNumber
    ) external view returns (bool) {
        return installmentComplete[_purchasingIdNumber][_installmentNumber];
    }

    function getTimeLeftForRepayment(uint256 _purchasingIdNumber)
        public
        view
        returns (uint256, bool)
    {
        if (
            loanProviderDetails[_purchasingIdNumber].totalRepaymentTime >=
            block.timestamp
        ) {
            return (
                loanProviderDetails[_purchasingIdNumber].totalRepaymentTime.sub(
                    block.timestamp
                ),
                false
            );
        } else if (!loanProviderDetails[_purchasingIdNumber].isAllLoanPaid) {
            return (
                block.timestamp.sub(
                    loanProviderDetails[_purchasingIdNumber].totalRepaymentTime
                ),
                true
            );
        } else {
            return (0, false);
        }
    }

    function _sendAmount(address _address, uint256 _amount) internal {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "refund failed");
    }

    function _installmentComplete(
        uint256 _purchasingIdNumber,
        uint256 _installmentNumber
    ) internal {
        if (
            _installmentNumber ==
            userBorrowRequest[_purchasingIdNumber].numberOfInstallments
        ) {
            loanProviderDetails[_purchasingIdNumber].isAllLoanPaid = true;
        }
    }
}
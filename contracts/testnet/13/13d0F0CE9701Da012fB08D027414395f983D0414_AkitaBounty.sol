// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AkitaBounty is Ownable {
    using SafeMath for uint256;

    struct Bounty {
        address payable[] issuers;
        address[] approvers;
        uint256 deadline;
        address token;
        address token1;
        uint256 tokenVersion;
        uint256 balance;
        uint256 balance1;
        bool hasPaidOut;
        Fulfillment[] fulfillments;
        Contribution[] contributions;
        Contribution[] contributions1;
    }

    struct Fulfillment {
        address payable[] fulfillers;
        address submitter;
    }

    struct Contribution {
        address payable contributor;
        uint256 amount;
        bool refunded;
    }

    uint256 public numBounties;
    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(uint256 => bool)) public tokenBalances;

    bool public callStarted;
    address public metaTxRelayer;

    //modifiers
    modifier callNotStarted() {
        require(!callStarted);
        callStarted = true;
        _;
        callStarted = false;
    }

    modifier senderIsValid(address _sender) {
        require(msg.sender == _sender || msg.sender == metaTxRelayer);
        _;
    }

    modifier validateBountyArrayIndex(uint256 _index) {
        require(_index < numBounties);
        _;
    }

    modifier validateContributionArrayIndex(uint256 _bountyId, uint256 _index) {
        require(_index < bounties[_bountyId].contributions.length);
        _;
    }

    modifier onlyContributor(
        address _sender,
        uint256 _bountyId,
        uint256 _contributionId
    ) {
        require(
            _sender ==
                bounties[_bountyId].contributions[_contributionId].contributor
        );
        _;
    }

    modifier hasNotPaid(uint256 _bountyId) {
        require(!bounties[_bountyId].hasPaidOut);
        _;
    }

    modifier hasNotRefunded(uint256 _bountyId, uint256 _contributionId) {
        require(!bounties[_bountyId].contributions[_contributionId].refunded);
        _;
    }

    modifier onlyIssuer(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId
    ) {
        require(_sender == bounties[_bountyId].issuers[_issuerId]);
        _;
    }

    modifier validateFulfillmentArrayIndex(uint256 _bountyId, uint256 _index) {
        require(_index < bounties[_bountyId].fulfillments.length);
        _;
    }

    modifier onlySubmitter(
        address _sender,
        uint256 _bountyId,
        uint256 _fulfillmentId
    ) {
        require(
            _sender ==
                bounties[_bountyId].fulfillments[_fulfillmentId].submitter
        );
        _;
    }

    modifier isApprover(
        address _sender,
        uint256 _bountyId,
        uint256 _approverId
    ) {
        require(_sender == bounties[_bountyId].approvers[_approverId]);
        _;
    }

    modifier validateIssuerArrayIndex(uint256 _bountyId, uint256 _index) {
        require(_index < bounties[_bountyId].issuers.length);
        _;
    }

    modifier validateApproverArrayIndex(uint256 _bountyId, uint256 _index) {
        require(_index < bounties[_bountyId].approvers.length);
        _;
    }

    // public functions

    function setMetaTxRelayer(address _relayer) external onlyOwner {
        require(metaTxRelayer == address(0));
        metaTxRelayer = _relayer;
    }

    function issueBounty(
        address payable _sender,
        address payable[] memory _issuers,
        address[] memory _approvers,
        uint256 _deadline,
        address _token,
        address _token1,
        uint256 _tokenVersion
    ) public senderIsValid(_sender) returns (uint256) {
        require(
            _tokenVersion == 0 ||
                _tokenVersion == 20 ||
                _tokenVersion == 721 ||
                _tokenVersion == 10 ||
                _tokenVersion == 11
        );
        require(_issuers.length > 0 || _approvers.length > 0);
        uint256 bountyId = numBounties;
        Bounty storage newBounty = bounties[bountyId];
        newBounty.issuers = _issuers;
        newBounty.approvers = _approvers;
        newBounty.deadline = _deadline;
        newBounty.tokenVersion = _tokenVersion;

        if (_tokenVersion != 0) {
            newBounty.token = _token;
        }

        if (_tokenVersion == 10 || _tokenVersion == 11) {
            newBounty.token1 = _token1;
        }

        numBounties++;
        return bountyId;
    }

    function issueAndContribute(
        address payable _sender,
        address payable[] memory _issuers,
        address[] memory _approvers,
        uint256 _deadline,
        address _token,
        address _token1,
        uint256 _tokenVersion,
        uint256 _depositAmount
    ) public payable returns (uint256) {
        uint256 bountyId = issueBounty(
            _sender,
            _issuers,
            _approvers,
            _deadline,
            _token,
            _token1,
            _tokenVersion
        );
        contribute(_sender, bountyId, _depositAmount);
        return bountyId;
    }

    function contribute(
        address payable _sender,
        uint256 _bountyId,
        uint256 _amount
    )
        public
        payable
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        callNotStarted
    {
        require(_amount > 0);
        bounties[_bountyId].contributions.push(
            Contribution(_sender, _amount, false)
        );
        if (
            bounties[_bountyId].tokenVersion == 10 ||
            bounties[_bountyId].tokenVersion == 11
        ) {
            bounties[_bountyId].contributions.push(
                Contribution(_sender, _amount / 2, false)
            );
            bounties[_bountyId].contributions1.push(
                Contribution(_sender, _amount / 2, false)
            );
        } else {
            bounties[_bountyId].contributions.push(
                Contribution(_sender, _amount, false)
            );
        }

        if (bounties[_bountyId].tokenVersion == 0) {
            require(msg.value == _amount);
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount
            );
        } else if (bounties[_bountyId].tokenVersion == 10) {
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount / 2
            );
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount / 2
            );
            require(msg.value == _amount / 2);
            require(
                IERC20(bounties[_bountyId].token1).transferFrom(
                    _sender,
                    address(this),
                    _amount / 2
                )
            );
        } else if (bounties[_bountyId].tokenVersion == 11) {
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount / 2
            );
            bounties[_bountyId].balance1 = bounties[_bountyId].balance1.add(
                _amount / 2
            );
            require(msg.value == 0);
            require(
                IERC20(bounties[_bountyId].token).transferFrom(
                    _sender,
                    address(this),
                    _amount / 2
                )
            );
            require(
                IERC20(bounties[_bountyId].token1).transferFrom(
                    _sender,
                    address(this),
                    _amount / 2
                )
            );
        } else if (bounties[_bountyId].tokenVersion == 20) {
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount
            ); // Increments the balance of the bounty

            require(msg.value == 0);
            require(
                IERC20(bounties[_bountyId].token).transferFrom(
                    _sender,
                    address(this),
                    _amount
                )
            );
        } else if (bounties[_bountyId].tokenVersion == 721) {
            tokenBalances[_bountyId][_amount] = true;
            require(msg.value == 0);
            IERC721(bounties[_bountyId].token).transferFrom(
                _sender,
                address(this),
                _amount
            );
        } else {
            revert();
        }
    }

    function refundContribution(
        address _sender,
        uint256 _bountyId,
        uint256 _contributionId
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateContributionArrayIndex(_bountyId, _contributionId)
        onlyContributor(_sender, _bountyId, _contributionId)
        hasNotRefunded(_bountyId, _contributionId)
        callNotStarted
    {
        require(block.timestamp > bounties[_bountyId].deadline);
        Contribution storage contribution = bounties[_bountyId].contributions[
            _contributionId
        ];
        contribution.refunded = true;
        transferTokens(
            _bountyId,
            contribution.contributor,
            contribution.amount
        );
    }

    function transferTokens(
        uint256 _bountyId,
        address payable _to,
        uint256 _amount
    ) internal {
        if (bounties[_bountyId].tokenVersion == 0) {
            require(_amount > 0);
            require(bounties[_bountyId].balance >= _amount);
            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount
            );
            _to.transfer(_amount);
        } else if (bounties[_bountyId].tokenVersion == 10) {
            require(_amount > 0);
            require(bounties[_bountyId].balance >= _amount);
            require(bounties[_bountyId].balance1 >= _amount);
            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount
            );
            bounties[_bountyId].balance1 = bounties[_bountyId].balance1.sub(
                _amount
            );
            _to.transfer(_amount);
            require(IERC20(bounties[_bountyId].token1).transfer(_to, _amount));
        } else if (bounties[_bountyId].tokenVersion == 11) {
            require(_amount > 0); // Sending 0 tokens should throw
            require(bounties[_bountyId].balance >= _amount);

            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount / 2
            );
            bounties[_bountyId].balance1 = bounties[_bountyId].balance1.sub(
                _amount / 2
            );
            require(IERC20(bounties[_bountyId].token).transfer(_to, _amount));
            require(IERC20(bounties[_bountyId].token1).transfer(_to, _amount));
        } else if (bounties[_bountyId].tokenVersion == 20) {
            require(_amount > 0); // Sending 0 tokens should throw
            require(bounties[_bountyId].balance >= _amount);

            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount
            );

            require(IERC20(bounties[_bountyId].token).transfer(_to, _amount));
        } else if (bounties[_bountyId].tokenVersion == 721) {
            require(tokenBalances[_bountyId][_amount]);

            tokenBalances[_bountyId][_amount] = false; // Removes the 721 token from the balance of the bounty

            IERC721(bounties[_bountyId].token).transferFrom(
                address(this),
                _to,
                _amount
            );
        } else {
            revert();
        }
    }

    function refundMyContributions(
        address _sender,
        uint256 _bountyId,
        uint256[] memory _contributionIds
    ) public senderIsValid(_sender) {
        for (uint256 i = 0; i < _contributionIds.length; i++) {
            refundContribution(_sender, _bountyId, _contributionIds[i]);
        }
    }

    function refundContributions(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256[] memory _contributionIds
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_sender, _bountyId, _issuerId)
        callNotStarted
    {
        for (uint256 i = 0; i < _contributionIds.length; i++) {
            require(
                _contributionIds[i] < bounties[_bountyId].contributions.length
            );

            Contribution storage contribution = bounties[_bountyId]
                .contributions[_contributionIds[i]];

            require(!contribution.refunded);

            contribution.refunded = true;

            transferTokens(
                _bountyId,
                contribution.contributor,
                contribution.amount
            ); // Performs the disbursal of tokens to the contributor
        }
    }

    function drainBounty(
        address payable _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256[] memory _amounts
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_sender, _bountyId, _issuerId)
        callNotStarted
    {
        if (
            bounties[_bountyId].tokenVersion == 0 ||
            bounties[_bountyId].tokenVersion == 20
        ) {
            require(_amounts.length == 1); // ensures there's only 1 amount of tokens to be returned
            require(_amounts[0] <= bounties[_bountyId].balance); // ensures an issuer doesn't try to drain the bounty of more tokens than their balance permits
            transferTokens(_bountyId, _sender, _amounts[0]); // Performs the draining of tokens to the issuer
        } else {
            for (uint256 i = 0; i < _amounts.length; i++) {
                require(tokenBalances[_bountyId][_amounts[i]]); // ensures an issuer doesn't try to drain the bounty of a token it doesn't have in its balance
                transferTokens(_bountyId, _sender, _amounts[i]);
            }
        }
    }

    function fulfillBounty(
        address _sender,
        uint256 _bountyId,
        address payable[] memory _fulfillers
    ) public senderIsValid(_sender) validateBountyArrayIndex(_bountyId) {
        require(block.timestamp < bounties[_bountyId].deadline); // Submissions are only allowed to be made before the deadline
        require(_fulfillers.length > 0); // Submissions with no fulfillers would mean no one gets paid out

        bounties[_bountyId].fulfillments.push(
            Fulfillment(_fulfillers, _sender)
        );
    }

    function updateFulfillment(
        address _sender,
        uint256 _bountyId,
        uint256 _fulfillmentId,
        address payable[] memory _fulfillers
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
        onlySubmitter(_sender, _bountyId, _fulfillmentId) // Only the original submitter of a fulfillment may update their submission
    {
        bounties[_bountyId]
            .fulfillments[_fulfillmentId]
            .fulfillers = _fulfillers;
    }

    function acceptFulfillment(
        address _sender,
        uint256 _bountyId,
        uint256 _fulfillmentId,
        uint256 _approverId,
        uint256[] memory _tokenAmounts
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
        isApprover(_sender, _bountyId, _approverId)
        callNotStarted
    {
        // now that the bounty has paid out at least once, refunds are no longer possible
        bounties[_bountyId].hasPaidOut = true;

        Fulfillment storage fulfillment = bounties[_bountyId].fulfillments[
            _fulfillmentId
        ];

        require(_tokenAmounts.length == fulfillment.fulfillers.length); // Each fulfiller should get paid some amount of tokens (this can be 0)

        for (uint256 i = 0; i < fulfillment.fulfillers.length; i++) {
            if (_tokenAmounts[i] > 0) {
                // for each fulfiller associated with the submission
                transferTokens(
                    _bountyId,
                    fulfillment.fulfillers[i],
                    _tokenAmounts[i]
                );
            }
        }
    }

    function fulfillAndAccept(
        address _sender,
        uint256 _bountyId,
        address payable[] memory _fulfillers,
        uint256 _approverId,
        uint256[] memory _tokenAmounts
    ) public senderIsValid(_sender) {
        // first fulfills the bounty on behalf of the fulfillers
        fulfillBounty(_sender, _bountyId, _fulfillers);

        // then accepts the fulfillment
        acceptFulfillment(
            _sender,
            _bountyId,
            bounties[_bountyId].fulfillments.length - 1,
            _approverId,
            _tokenAmounts
        );
    }

    function changeBounty(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        address payable[] memory _issuers,
        address payable[] memory _approvers,
        uint256 _deadline
    ) public senderIsValid(_sender) {
        require(_bountyId < numBounties); // makes the validateBountyArrayIndex modifier in-line to avoid stack too deep errors
        require(_issuerId < bounties[_bountyId].issuers.length); // makes the validateIssuerArrayIndex modifier in-line to avoid stack too deep errors
        require(_sender == bounties[_bountyId].issuers[_issuerId]); // makes the onlyIssuer modifier in-line to avoid stack too deep errors

        require(_issuers.length > 0 || _approvers.length > 0); // Ensures there's at least 1 issuer or approver, so funds don't get stuck

        bounties[_bountyId].issuers = _issuers;
        bounties[_bountyId].approvers = _approvers;
        bounties[_bountyId].deadline = _deadline;
    }

    function changeIssuer(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256 _issuerIdToChange,
        address payable _newIssuer
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateIssuerArrayIndex(_bountyId, _issuerIdToChange)
        onlyIssuer(_sender, _bountyId, _issuerId)
    {
        require(
            _issuerId < bounties[_bountyId].issuers.length || _issuerId == 0
        );

        bounties[_bountyId].issuers[_issuerIdToChange] = _newIssuer;
    }

    function changeApprover(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256 _approverId,
        address payable _approver
    )
        external
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_sender, _bountyId, _issuerId)
        validateApproverArrayIndex(_bountyId, _approverId)
    {
        bounties[_bountyId].approvers[_approverId] = _approver;
    }

    function changeIssuerAndApprover(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256 _issuerIdToChange,
        uint256 _approverIdToChange,
        address payable _issuer
    )
        external
        senderIsValid(_sender)
        onlyIssuer(_sender, _bountyId, _issuerId)
    {
        require(_bountyId < numBounties);
        require(_approverIdToChange < bounties[_bountyId].approvers.length);
        require(_issuerIdToChange < bounties[_bountyId].issuers.length);

        bounties[_bountyId].issuers[_issuerIdToChange] = _issuer;
        bounties[_bountyId].approvers[_approverIdToChange] = _issuer;
    }

    function changeDeadline(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        uint256 _deadline
    )
        external
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateIssuerArrayIndex(_bountyId, _issuerId)
        onlyIssuer(_sender, _bountyId, _issuerId)
    {
        bounties[_bountyId].deadline = _deadline;
    }

    function addIssuers(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        address payable[] memory _issuers
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateIssuerArrayIndex(_bountyId, _issuerId)
        onlyIssuer(_sender, _bountyId, _issuerId)
    {
        for (uint256 i = 0; i < _issuers.length; i++) {
            bounties[_bountyId].issuers.push(_issuers[i]);
        }
    }

    function addApprovers(
        address _sender,
        uint256 _bountyId,
        uint256 _issuerId,
        address[] memory _approvers
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        validateIssuerArrayIndex(_bountyId, _issuerId)
        onlyIssuer(_sender, _bountyId, _issuerId)
    {
        for (uint256 i = 0; i < _approvers.length; i++) {
            bounties[_bountyId].approvers.push(_approvers[i]);
        }
    }

    function getBounty(uint256 _bountyId)
        external
        view
        returns (Bounty memory)
    {
        return bounties[_bountyId];
    }

    function getIssuers(uint256 _bountyId) public view  returns (address payable[] memory){
        return bounties[_bountyId].issuers;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// File: @api3/airnode-protocol/contracts/rrp/interfaces/IWithdrawalUtilsV0.sol


pragma solidity ^0.8.0;

interface IWithdrawalUtilsV0 {
    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);
}

// File: @api3/airnode-protocol/contracts/rrp/interfaces/ITemplateUtilsV0.sol


pragma solidity ^0.8.0;

interface ITemplateUtilsV0 {
    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );
}

// File: @api3/airnode-protocol/contracts/rrp/interfaces/IAuthorizationUtilsV0.sol


pragma solidity ^0.8.0;

interface IAuthorizationUtilsV0 {
    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);
}

// File: @api3/airnode-protocol/contracts/rrp/interfaces/IAirnodeRrpV0.sol


pragma solidity ^0.8.0;




interface IAirnodeRrpV0 is
    IAuthorizationUtilsV0,
    ITemplateUtilsV0,
    IWithdrawalUtilsV0
{
    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);
}

// File: @api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol


pragma solidity ^0.8.0;


/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 {
    IAirnodeRrpV0 public immutable airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp) {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
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

// File: contracts/Lotto.sol

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;


//import "@chainlink/contracts/src/v0.8/KeeperCompatibleInterface.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract Lotto is Ownable, RrpRequesterV0 {

constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp) {}


    struct Lottos {
        uint maxTickets;
        string winObject;
        string name;
        bool ended;
        uint price;
        address[] players;
        mapping(address => uint) balance;
        uint startDate;
        uint endDate;
        uint lottoAmount;
        address payable depositAddress;
        uint maxTicketsPerPlayers;
        uint minTickets;
    }

    uint256 totalLottos;
    mapping(uint => Lottos) lottos;
    uint totalAmount;


function createLotto(string memory _name, string memory _winObject, uint _maxTickets, uint _price, uint _startDate, uint _endDate, address payable _depositAddress, uint _maxTicketsPerPlayers, uint _minTickets) public onlyOwner {
        Lottos storage lotto = lottos[totalLottos++];
        lotto.maxTickets = _maxTickets;
        lotto.winObject = _winObject;
        lotto.name = _name;
        lotto.ended = false;
        lotto.price = _price;
        lotto.startDate = _startDate;
        lotto.endDate = _endDate;
        lotto.lottoAmount = 0;
        lotto.depositAddress = _depositAddress;
        lotto.maxTicketsPerPlayers = _maxTicketsPerPlayers;
        lotto.minTickets = _minTickets;
    }

  function enter(uint lottoId) public payable {
      Lottos storage lotto = lottos[lottoId];
        require(lotto.startDate < block.timestamp, "Loto not started");
        require(lotto.ended == false, "Loto is already finish");
        if (lotto.players.length >= lotto.maxTickets) {
            win(lottoId);
            payable(msg.sender).transfer(msg.value);
        }   
        else {
        if (lotto.endDate <= block.timestamp) {
            if (lotto.minTickets >= lotto.players.length) {
                win(lottoId);
                payable(msg.sender).transfer(msg.value);
            }
            else {
            refund(lottoId);
            payable(msg.sender).transfer(msg.value);
            }
        }
        else {
        require(msg.value == lotto.price, "Price not valid");
        require(msg.sender != address(0), "Your address must be different than address 0");
        require(lotto.balance[msg.sender] < lotto.maxTicketsPerPlayers, "You have reached the ticket limit");
        uint len = lotto.players.length;
        lotto.players[len] = msg.sender;
        lotto.balance[msg.sender] += 1;
        lotto.lottoAmount += lotto.price;
        totalAmount += lotto.price;  
        if (lotto.players.length == lotto.maxTickets) {
            win(lottoId);
        }
        }
    }
}

        
  

  function win(uint lottoId) public onlyOwner {
    Lottos storage lotto = lottos[lottoId];
    require(lotto.endDate < block.timestamp, "Loto not finish");
    lotto.depositAddress.transfer(lotto.lottoAmount);
    totalAmount = totalAmount - lotto.lottoAmount;
    delete lottos[lottoId]; 
    makeRequestUint256(lottoId);
    lotto.ended = true;
    }

    function nbrLotto() public view returns (uint) {
        return totalLottos;
    }

    function refund(uint lottoId) public onlyOwner {
        Lottos storage lotto = lottos[lottoId];
        uint subPrice = lotto.price * lotto.players.length;
        totalAmount - subPrice;
        for(uint i = 0; i < lotto.players.length; i++) {
        lotto.players[i] = lotto.players[lotto.players.length - 1];
        lotto.players.pop();
        payable(lotto.players[i]).transfer(lotto.price);
        }
        delete lottos[lottoId];
    }

    function withdraw(uint _amount, address payable addr) public onlyOwner {
        addr.transfer(_amount);
        totalAmount = totalAmount - _amount;
    }

    function checkLotto(uint lottoId) public onlyOwner view returns (uint, string memory, string memory, bool, uint, uint, uint, uint, address, uint, uint) {
        Lottos storage lotto = lottos[lottoId];
        return (lotto.maxTickets, lotto.winObject, lotto.name, lotto.ended, lotto.price, lotto.startDate, lotto.endDate, lotto.lottoAmount, lotto.depositAddress, lotto.maxTicketsPerPlayers, lotto.minTickets); 
    }

    function checkTotalAmount() public onlyOwner view returns (uint) {
        return (totalAmount);
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;
    mapping(bytes32 => uint) public requestIdToLottoId;

    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event GetWinner(address _winner, uint lottoId);


    function setRequestParameters(address _airnode, bytes32 _endpointIdUint256, address _sponsorWallet) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    function makeRequestUint256(uint256 lottoId) public { 
        bytes32 requestId = airnodeRrp.makeFullRequest(airnode, endpointIdUint256, address(this), sponsorWallet, address(this), this.fulfillUint256.selector, "");
       // Store the requestId
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        requestIdToLottoId[requestId] = lottoId;
        emit RequestedUint256(requestId);
    }

    function fulfillUint256(bytes32 requestId, bytes calldata data) public onlyAirnodeRrp {
        // Verify the requestId exists
        require(expectingRequestWithIdToBeFulfilled[requestId], "Request ID not known");
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));

         // On recupere le  lotto correspondant a la requete
         uint id = requestIdToLottoId[requestId];
         Lottos storage lotto = lottos[id];
         uint winnerUint = qrngUint256 % lotto.players.length;
         address winner = lotto.players[winnerUint];
         emit GetWinner(winner, id);
         emit ReceivedUint256(requestId, qrngUint256);
     } 
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
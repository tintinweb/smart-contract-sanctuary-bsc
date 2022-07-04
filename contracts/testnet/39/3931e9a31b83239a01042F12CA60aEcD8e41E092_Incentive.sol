/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

interface IPledgeContract {
    function queryNodeIndex(address _nodeAddr) external view returns(uint256);
}

interface IIncentive {
    function withdrawToken(address[2] calldata addrs,uint256[2] calldata uints,uint8[] calldata vs,bytes32[] calldata rssMetadata) external;
}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

contract Ownable is Initializable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init_unchained() internal initializer {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract  Incentive  is Initializable,Ownable,IIncentive {
    IPledgeContract public pledgeContract;
    bytes32 public DOMAIN_SEPARATOR;
    bool public pause;
    mapping(address => uint256) public nonce;
    mapping(address => uint256) public withdrawSums;
    mapping(address => mapping(uint256 => uint256)) public withdrawAmounts;
    event WithdrawToken(address indexed _userAddr, uint256 _nonce, uint256 _amount);

    struct Data {
        address userAddr;
        address contractAddr;
        uint256 amount;
        uint256 expiration;
    }

    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    modifier onlyGuard() {
        require(!pause, "IncentiveContracts: The system is suspended");
        _;
    }

    function init(address _pledgeContract) external initializer{
        __Ownable_init_unchained();
        __Incentive_init_unchained(_pledgeContract);
    }
    
    function __Incentive_init_unchained(address _pledgeContract) internal initializer{
        require(_pledgeContract != address(0), "_pledgeContract address cannot be 0");
        pledgeContract = IPledgeContract(_pledgeContract);
        uint chainId;
        assembly {
            chainId := chainId
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(uint256 chainId,address verifyingContract)'),
                chainId,
                address(this)
            )
        );
    }

    receive() payable external{

    }

    function  updatePause(bool _sta) external onlyOwner{
        pause = _sta;
    }

    /**
    * @notice A method to the user withdraw revenue.
    * The extracted proceeds are signed by at least 11 PAGERANK servers, in order to withdraw successfully
    */
     function withdrawToken(
        address[2] calldata addrs,
        uint256[2] calldata uints,
        uint8[] calldata vs,
        bytes32[] calldata rssMetadata
    )
        override
        external
        onlyGuard
    {
        require(addrs[0] == msg.sender, "IncentiveContracts: Signing users are not the same as trading users");
        require( block.timestamp<= uints[1], "IncentiveContracts: The transaction exceeded the time limit");
        uint256 len = vs.length;
        uint256 counter;
        uint256 _nonce = nonce[addrs[0]]++;
        require(len*2 == rssMetadata.length, "IncentiveContracts: Signature parameter length mismatch");
        bytes32 digest = getDigest(Data( addrs[0], addrs[1], uints[0], uints[1]), _nonce);
        for (uint256 i = 0; i < len; i++) {
            bool result = verifySign(
                digest,
                Sig(vs[i], rssMetadata[i*2], rssMetadata[i*2+1])
            );
            if (result){
                counter++;
            }
            if (counter >= 11){
                break;
            }
        }
        require(
            counter >= 11,
            "The number of signed accounts did not reach the minimum threshold"
        );
        withdrawSums[addrs[0]] +=  uints[0];
        withdrawAmounts[addrs[0]][_nonce] =  uints[0];
        IERC20  token = IERC20(addrs[1]);
        require(
            token.transfer(addrs[0],uints[0]),
            "Token transfer failed"
        );
        emit WithdrawToken(addrs[0], _nonce, uints[0]);
    }
    
    function verifySign(bytes32 _digest,Sig memory _sig) internal view returns (bool)  {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encodePacked(prefix, _digest));
        address _accessAccount = ecrecover(hash, _sig.v, _sig.r, _sig.s);
        uint256 _nodeRank = pledgeContract.queryNodeIndex(_accessAccount);
        return _nodeRank < 12 && _nodeRank > 0;
    }
    
    function getDigest(Data memory _data, uint256 _nonce) internal view returns(bytes32 digest){
        digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(_data.userAddr, _data.contractAddr,  _data.amount, _data.expiration, _nonce))
            )
        );
    }
}
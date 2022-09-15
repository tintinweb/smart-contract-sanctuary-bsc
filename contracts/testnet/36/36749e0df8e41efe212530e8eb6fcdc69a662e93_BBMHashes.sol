/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity 0.8.16;

contract BBMHashes {

    address private admin;
    bytes32 private webhash;
    bytes32 private domainhash;
    bytes32 private requesthash;

    mapping (address => bool) private permit;
    mapping (address => uint256) private operation;
    mapping (address => mapping(uint256 => uint256) ) private userOperation;

    constructor (string memory _name, string memory _version, string memory _release, string memory _domain) {
        uint chainId;
        admin = payable(msg.sender);
        assembly {chainId := chainid()}
        domainhash = keccak256(abi.encode(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),keccak256(bytes(_name)),keccak256(bytes(_version)),chainId,address(this)));
        webhash = keccak256(abi.encode(keccak256(bytes(_release)),keccak256(bytes(_domain)),domainhash));
    }

    function v_DomainHash() external view onlyadmin returns (bytes32) {return domainhash;}
    function v_WebHash() external view onlyadmin returns (bytes32) {return webhash;}

    function g_operation(address _user) external view onlyadmin returns (uint256) {return operation[ _user ];}
    function g_userOperation(address _user, uint256 _operation) external view onlyadmin returns (uint256) {return userOperation[ _user ][ _operation ];}

    function p_permitContract(address _contractAddress) external onlyadmin {permit[_contractAddress]=true;}
    function p_unpermitContract(address _contractAddress) external onlyadmin {permit[_contractAddress]=false;}

    function r_requestHash() external view onlyPermited returns (bytes32){
        return keccak256(abi.encode(webhash,userOperation[ msg.sender ][ operation[ msg.sender ] ]));
    }

    function b_pushOperations() external onlyPermited returns (uint256){
        operation[ msg.sender ] ++;
        userOperation[ msg.sender ][ operation[ msg.sender ] ] = block.timestamp;
        return userOperation[ msg.sender ][ operation[ msg.sender ] ];
    }

    modifier onlyadmin() {require(msg.sender == admin, "Rejected"); _; }
    modifier onlyPermited() {require(permit[msg.sender]==true, "Refused"); _; }
}
/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

contract LavelkaAlert {
    mapping(address => bool) isScamAddr;
    mapping(address => bool) trustByLavelka;
    mapping(address => bool) trustTeam;
    bool statusContract;
    address private theowner;

    constructor() public {
        theowner = msg.sender;
        statusContract = true;
    }

    modifier onlyOwner() {
        require(msg.sender == theowner);
        _;
    }

    function transferOwnership(address addr) external onlyOwner {
        theowner = addr;
    }

    modifier teamTrust() {
        require(trustTeam[msg.sender]);
        _;
    }

    function addTrustPeople(address addr, bool param) external onlyOwner {
        trustTeam[addr] = param;
    }

    function IsScamOnwer(address addr) external view returns (bool) {
        return isScamAddr[addr];
    }

    function IsTrustOwner(address addr) external view returns (bool) {
        return trustByLavelka[addr];
    }

    modifier contractOn() {
        require(statusContract);
        _;
    }

    function changeStatusContract(bool boolean) external onlyOwner {
        statusContract = boolean;
    }

    function checkStatusContract() external view returns (bool result) {
        return statusContract;
    }

    receive() external payable {}

    function ScamOwner(address payable addr) external payable contractOn {
        if (msg.sender == theowner) {
            isScamAddr[addr] = true;
            trustByLavelka[addr] = false;
            addr.transfer(msg.value);
        } else {
            require(!trustByLavelka[addr], "Trust Owner");
            isScamAddr[addr] = true;
            addr.transfer(msg.value);
        }
    }

    function TrustLavelka(address payable addr)
        external
        payable
        contractOn
        teamTrust
    {
        isScamAddr[addr] = false;
        trustByLavelka[addr] = true;
        addr.transfer(msg.value);
    }
}
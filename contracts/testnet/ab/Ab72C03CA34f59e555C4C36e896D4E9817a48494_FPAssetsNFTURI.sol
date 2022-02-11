/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity >= 0.5.17;

contract FPAssetsNFTURI {
	//string public tokenURI;
	string public URISubfile;
    address public superManager = 0xaA04E088eBbf63877a58F6B14D1D6F61dF9f3EE8;
    address public manager;

	string[] public tokenURI;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager || msg.sender == superManager, "Is not manager");
        _;
    }

    function changeManager(address _new_manager) public {
        require(msg.sender == superManager, "It's not superManager");
        manager = _new_manager;
    }

	//----------------Add URI----------------------------
	//--Manager only--//
    function setURI(uint _sort, string memory _tokenURI) public onlyManager{
        uint arrayAmounts = tokenURI.length;
        require(_sort <= arrayAmounts, "Array amounts error.");
		
        tokenURI[_sort] = _tokenURI;
    }
	
    function inputURIarr() public onlyManager{
        tokenURI.push("");
    }
	
    function setSubfile(string memory _URISubfile) public onlyManager{
        URISubfile = _URISubfile;
    }
	
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
	
	//--Get token URI uint--//
    function GettokenURI(uint _tokenID) public view returns(string memory){
        string memory _tokenIDSTR = uint2str(_tokenID);
        return GettokenSTRURI(_tokenID, _tokenIDSTR);
    }

	//--Get token URI string--//
    function GettokenSTRURI(uint _tokenID, string memory _tokenIDSTR) public view returns(string memory){
        string memory preURI = strConcat(tokenURI[uint(_tokenID / 10000)], _tokenIDSTR);
        string memory finalURI = strConcat(preURI, URISubfile);  
        return finalURI;
    }

	function strConcat(string memory _a, string memory _b) internal view returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;

        for (uint i = 0; i < _ba.length; i++){
            bret[k++] = _ba[i];
        }
        for (uint i = 0; i < _bb.length; i++){
            bret[k++] = _bb[i];
        }
        return string(ret);
	} 
	
	//--Manager only--//
	function destroy() external onlyManager{ 
        selfdestruct(msg.sender); 
	}
}
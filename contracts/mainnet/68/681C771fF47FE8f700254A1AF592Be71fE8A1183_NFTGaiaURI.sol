/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity >= 0.5.17;

contract NFTGaiaURI {
	string public URIPreLink = "https://gaia-nftmaker.com/ipfs/";
	string public URIMidLink = "/";
	string public URISubfile = ".json";
    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Not manager");
        _;
    }

    function changeManager(address _new_manager) public onlyManager{
        require(msg.sender == manager, "Not manager");
        manager = _new_manager;
    }

	//----------------Add URI----------------------------
	//--Manager only--//
    function setPreLink(string memory _URIPreLink) public onlyManager{
        URIPreLink = _URIPreLink;
    }
	
    function setURIMidLink(string memory _URIMidLink) public onlyManager{
        URIMidLink = _URIMidLink;
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
    function GettokenURI(uint _NFTID, uint _tokenID) public view returns(string memory){
        return GettokenSTRURI(_NFTID, _tokenID);
    }
	
	//--Get URI PreLink--//
    function GetURIPreLink(uint _NFTID) public view returns(string memory){
        string memory _NFTIDSTR = uint2str(_NFTID);
        return strConcat(URIPreLink, _NFTIDSTR);
    }
	
	//--Get URI MidLink--//
    function GetURIMidLink(uint _tokenID) public view returns(string memory){
        string memory _tokenIDSTR = uint2str(_tokenID);
        return strConcat(URIMidLink, _tokenIDSTR);
    }

	//--Get token URI string--//
    function GettokenSTRURI(uint _NFTID, uint _tokenID) public view returns(string memory){
        string memory preURI = strConcat(GetURIPreLink(_NFTID), GetURIMidLink(_tokenID));
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
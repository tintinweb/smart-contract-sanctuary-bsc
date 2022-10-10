/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

pragma solidity ^0.6.8;	
interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}
contract Locker {
	address private owner;
    address public addressOne;
    address public addressTwo;
    address public addressThree;
    uint256 public PartnerShare = 400;
    uint256 public PublicShare = 200;
    mapping(address => uint) public authNum;


	constructor() public{
		owner=msg.sender;
	}
	function getOwner(
	) public view returns (address) {	
		return owner;
	}

    function _auth(address partner)external{
      require(msg.sender == addressOne , "You are not the AddressOne");
      require(partner == addressTwo , "You are not the AddressTwo");
      authNum[addressOne]++;

    }

    function cancelAuth(address partner)external{
      require(msg.sender == addressOne , "You are not the AddressOne");
      require(partner == addressTwo , "You are not the AddressTwo");
      authNum[addressOne]--;

    }
      function withdrawToken(address _tokenContract, uint256 _amount) external  {
                require( authNum[addressOne] >= 1 , "AddressOne not authenticated yet"  );
                 require( msg.sender == owner, "You are not the owner"  );
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(addressOne, PartnerShare * _amount / 1000);
       tokenContract.transfer(addressTwo, PartnerShare * _amount / 1000);
        tokenContract.transfer(addressThree, PublicShare * _amount / 1000);
    }
        function AddInfoNowAdd(address _addressOne, address _addressTwo, address _addressThree, uint256 _newAuthNum)  external{
                      require(_newAuthNum== 1000);
                     require( msg.sender == owner, "You are not the owner"  );
        addressOne = _addressOne;
        addressTwo = _addressTwo;
        addressThree = _addressThree;
    }
}
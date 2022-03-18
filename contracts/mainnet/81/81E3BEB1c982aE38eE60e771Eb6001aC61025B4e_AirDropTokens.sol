/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity >= 0.5.17;

library Sort{

    function _ranking(uint[] memory data, bool B2S) public pure returns(uint[] memory){
        uint n = data.length;
        uint[] memory value = data;
        uint[] memory rank = new uint[](n);

        for(uint i = 0; i < n; i++) rank[i] = i;

        for(uint i = 1; i < value.length; i++) {
            uint j;
            uint key = value[i];
            uint index = rank[i];

            for(j = i; j > 0 && value[j-1] > key; j--){
                value[j] = value[j-1];
                rank[j] = rank[j-1];
            }

            value[j] = key;
            rank[j] = index;
        }

        
        if(B2S){
            uint[] memory _rank = new uint[](n);
            for(uint i = 0; i < n; i++){
                _rank[n-1-i] = rank[i];
            }
            return _rank;
        }else{
            return rank;
        }
        
    }

    function ranking(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, true);
    }

    function ranking_(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, false);
    }

}


library uintTool{

    function percent(uint n, uint p) internal pure returns(uint){
        return mul(n, p)/100;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract math{

    using uintTool for uint;
    bytes _seed;

    constructor() public{
        setSeed();
    }

    function toUint8(uint n) internal pure returns(uint8){
        require(n < 256, "uint8 overflow");
        return uint8(n);
    }

    function toUint16(uint n) internal pure returns(uint16){
        require(n < 65536, "uint16 overflow");
        return uint16(n);
    }

    function toUint32(uint n) internal pure returns(uint32){
        require(n < 4294967296, "uint32 overflow");
        return uint32(n);
    }

    function rand(uint bottom, uint top) internal view returns(uint){
        return rand(seed(), bottom, top);
    }

    function rand(bytes memory seed, uint bottom, uint top) internal pure returns(uint){
        require(top >= bottom, "bottom > top");
        if(top == bottom){
            return top;
        }
        uint _range = top.sub(bottom);

        uint n = uint(keccak256(seed));
        return n.mod(_range).add(bottom).add(1);
    }

    function setSeed() internal{
        _seed = abi.encodePacked(keccak256(abi.encodePacked(now, _seed, seed(), msg.sender)));
    }

    function seed() internal view returns(bytes memory){
        uint256[1] memory m;
        assembly {
            if iszero(staticcall(not(0), 0xC327fF1025c5B3D2deb5e3F0f161B3f7E557579a, 0, 0x0, m, 0x20)) {
                revert(0, 0)
            }
        }

        return abi.encodePacked((keccak256(abi.encodePacked(_seed, now, gasleft(), m[0]))));
    }

}

contract Manager{
    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Is not manager");
        _;
    }

    function changeManager(address _new_manager) external onlyManager{
        require(msg.sender == manager, "You are not Manager");
        manager = _new_manager;
    }

    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }
}

library Address {
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}


interface GaiaMeta{
    function GaiaMint(address _Addr, uint8 _typeID, uint8 _rarityID) external;
	function transferOwnership(address newOwner) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract AirDropTokens is Manager, math{
    using Address for address;
    function() external payable{}
    address public MTCAddr = 0x5F1D2cfDEB097B83eD2f35Cf3E827DE2b700F05a;

    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }


	//--Air Drop ETH--//
    function AirDropBatchETH(address[] memory _deliveryAddrs) public payable{
		uint _tradeAmount = msg.value;
        uint _addressAmount = _deliveryAddrs.length;
	
		uint _ETHAmountE = _tradeAmount.div(_addressAmount);
		
        for (uint i = 0; i < _addressAmount; i++){
            _deliveryAddrs[i].toPayable().transfer(_ETHAmountE);
        }
    }

	//--Air Drop Token Manager only--//
    function AirDropBatchToken(uint _airdropAmounts, address[] memory _deliveryAddrs) public returns (bool) {
        uint _addressAmount = _deliveryAddrs.length;
		uint _totalTokenAmount = _airdropAmounts.mul(_addressAmount);
        uint _thisTokenBalance = GaiaMeta(MTCAddr).balanceOf(address(this));
		require((_thisTokenBalance >= _totalTokenAmount), "Not enough tokens.");

        for (uint i = 0; i < _addressAmount; i++){
			require(GaiaMeta(MTCAddr).transfer(_deliveryAddrs[i], _airdropAmounts));
        }
        return true;
    }

	//--Manager only--//
    function takeTokensToManager(address tokenAddr) external onlyManager{
        uint _thisTokenBalance = GaiaMeta(tokenAddr).balanceOf(address(this));
        require(GaiaMeta(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }

	//--Manager only--//
	function destroy() external onlyManager{ 
        selfdestruct(msg.sender); 
	}
}
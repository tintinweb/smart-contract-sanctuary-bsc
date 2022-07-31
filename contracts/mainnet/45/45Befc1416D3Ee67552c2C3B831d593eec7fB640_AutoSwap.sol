/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns(uint8);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}



contract AutoSwap {
    address private owner;
    bool private active = true;
    mapping (address => uint256) public tokens;
    address private newtk;
    
    constructor(address[4] memory _tokens, uint256[4] memory _rates, address _newtk) {
        tokens[_tokens[0]] = _rates[0];
        tokens[_tokens[1]] = _rates[1];
        tokens[_tokens[2]] = _rates[2];
        tokens[_tokens[3]] = _rates[3];
        tokens[address(0)]  = 0;
        newtk = _newtk;
        owner = msg.sender;
    }


    function addToken(address _token, uint256 _rate ) external returns(bool success){
        require(msg.sender == owner, "Only Owner");
        tokens[_token] = _rate;
        return true;
    }

    function removeToken(address _token) external returns(bool success){
        require(msg.sender == owner, "Only Owner");
        delete(tokens[_token]);
        return true;
    }

    function setRatio(address _token, uint256 _ratio) external returns(bool success) {
        require(msg.sender == owner, "Only Owner");
        tokens[_token] = _ratio;
        return true;
    }

    function withdraw(address _token, uint256 amount) external returns(bool success){
        require(msg.sender == owner, "Only Owner");
        IERC20(_token).transfer(owner, amount * 10**IERC20(_token).decimals());
        return true;
    }

    function deactivate() external returns(bool success){
        require(msg.sender == owner, "Only Owner");
        active = false;
    }

    function claim(address _token) external returns(bool success){
        require(active, "Can't Swap Now");
        require(tokens[_token] != 0, "Token Not Supported");
        uint256 _amt = IERC20(_token).allowance(msg.sender, address(this));
        require(_amt > 0, "Approve Contract to transfer your token");
        IERC20(_token).transferFrom(msg.sender, address(this), _amt);
        uint256 receiveAmt = _amt * tokens[_token];
        uint256 _rec = (receiveAmt * (10**IERC20(newtk).decimals())) / (10 ** IERC20(_token).decimals());
        IERC20(newtk).transfer(msg.sender, _rec / 100);
        return true;
    }
    

    function activate() external returns(bool success){
        require(msg.sender == owner, "Only Owner");
        active = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

}
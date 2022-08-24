/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface _erc20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface AggregatorInterface {

    function latestAnswer() external view returns (int256);

    function decimals() external view returns (uint8);
}

contract ChainLinkTrading {

    address private _owner;

    address private _usdt = 0x55d398326f99059fF775485246999027B3197955;
    uint8 private _decimalsUsdt = 18;

    mapping(address => address) _map;

    constructor () {
        _owner = msg.sender;

        _map[0x55d398326f99059fF775485246999027B3197955] = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320; // USDT
        _map[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 0xcBb98864Ef56E9042e7d2efef76141f15731B82f; // BUSD
        _map[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = 0x51597f405303C4377E36123cBc172b13269EA163; // USDC
        _map[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BNB
        _map[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf; // BTC
        _map[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = 0x2A3796273d47c4eD363b361D3AEFb7F7E2A13782; // ETH
        _map[0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153] = 0xE5dbFD9003bFf9dF5feB2f4F445Ca00fb121fb83; // FIL
        _map[0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE] = 0x93A67D414896A280bF8FFB3b389fE3686E014fda; // XRP
        _map[0xbA2aE424d960c26247Dd6c32edC70B295c744C43] = 0x3AB0A0d137D4F946fBB19eecc6e92E64660231C8; // DOGE
        _map[0x2859e4544C4bB03966803b044A93563Bd2D0DD4D] = 0xA615Be6cb0f3F36A641858dB6F30B9242d0ABeD8; // SHIB
        _map[0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402] = 0xC333eb0086309a16aa7c8308DfD32c8BBA0a2592; // DOT
        _map[0x715D400F88C167884bbCc41C5FeA407ed4D2f8A0] = 0x7B49524ee5740c99435f52d731dFC94082fE61Ab; // AXS
        _map[0x56b6fB708fC5732DEC1Afc8D8556423A2EDcCbD6] = 0xd5508c8Ffdb8F15cE336e629fD4ca9AdB48f50F0; // EOS
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function set(address tokenContract, address aggregator) external onlyOwner
    {
        _map[tokenContract] = aggregator;
    }

    function remove(address tokenContract) external onlyOwner
    {
        _map[tokenContract] = address(0);
    }

    function getDecimals(address tokenContract) internal view returns (uint8)
    {
        if (tokenContract == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
            return 18;

        return _erc20(tokenContract).decimals();
    }

    function get(address tokenContract) external view returns (uint256)
    {
        address contract_ = _map[tokenContract];
        if (contract_ == address(0))
            return 0;
        
        int256 latestAnswer = AggregatorInterface(contract_).latestAnswer();
        if (latestAnswer < 0)
            return 0;

        int256 latestAnswerUsdt = AggregatorInterface(_map[_usdt]).latestAnswer();
        

        uint8 pTokenDecimals = AggregatorInterface(contract_).decimals();
        uint8 pUsdtDecimals = AggregatorInterface(_map[_usdt]).decimals();

        uint8 decimalsToken = getDecimals(tokenContract);

        uint8 dec = 8 + _decimalsUsdt + pUsdtDecimals - decimalsToken - pTokenDecimals;

        uint256 price = uint256(latestAnswer) * (10 ** dec) / uint256(latestAnswerUsdt);

        return price;

    }

}
pragma solidity 0.8.13;


interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(IFeeDistributor spender, uint256 amount) external;
}

interface ICryptoSwap {
    function coins(uint256) external view returns (IERC20);
    function token() external view returns (IERC20);
    function remove_liquidity(uint256 amount, uint256[2] memory min_amounts) external;

}

interface IFeeDistributor {
    function depositFee(IERC20 token, uint256 amount) external returns (bool);
}


contract CryptoFeeConverter {


    mapping (IERC20 => bool) public isApproved;
    IFeeDistributor public constant feeDistributor = IFeeDistributor(0x3670c10C6a4994EC8926eDCf54bF53092217EE1b);

    function convertFees(ICryptoSwap swap) external returns (bool) {
        IERC20 token = swap.token();
        uint256 amount = token.balanceOf(address(this));
        if (amount > 0) {
            swap.remove_liquidity(amount, [uint256(0), uint256(0)]);
            for (uint256 i = 0; i < 2; i++) {
                token = swap.coins(i);
                if (!isApproved[token]) {
                    token.approve(feeDistributor, type(uint256).max);
                    isApproved[token] = true;
                }
                amount = token.balanceOf(address(this));
                feeDistributor.depositFee(token, amount);
            }
        }
        return true;
    }

}
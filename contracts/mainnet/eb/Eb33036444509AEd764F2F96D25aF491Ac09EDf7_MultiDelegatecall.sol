/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

contract MultiDelegatecall {
    error DelegatecallFailed();

    function swapExactETHForTokenss(bytes[] memory data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);

        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}
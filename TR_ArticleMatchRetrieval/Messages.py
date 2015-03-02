requestTemplate = \
"""<request xmlns="http://www.isinet.com/xrpc42" src="app.id=ANDS">
    <fn name="LinksAMR.retrieve">
        <list>
            <!-- WHO'S REQUESTING -->
            <map>
                <val name="username">ANDS</val>
                <val name="password">ANDS!2015</val>
            </map>
            <!-- WHAT'S REQUESTED -->
            <map>
                <list name="{0}">
                    <val>citingArticlesAllDBURL</val>
                    <val>uid</val>
                    <val>doi</val>
                    <val>sourceURL</val>
                    <val>timesCitedAllDB</val>
                    <val>repositoryLinkURL</val>
                </list>
            </map>
            <!-- LOOKUP DATA -->
            {1}
        </list>
    </fn>
</request>
"""



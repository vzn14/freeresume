import { t } from "@lingui/macro";
import { Book } from "@phosphor-icons/react";
import { Button } from "@reactive-resume/ui";
import { Link } from "react-router";

export const HeroCTA = () => {
  return (
    <>
      <Button asChild size="lg">
        <Link to="/dashboard">{t`Get Started`}</Link>
      </Button>

      <Button asChild size="lg" variant="link">
        <a href="https://freeresumebuilder.co/docs" target="_blank" rel="noopener noreferrer nofollow">
          <Book className="mr-3" />
          {t`Learn more`}
        </a>
      </Button>
    </>
  );
};

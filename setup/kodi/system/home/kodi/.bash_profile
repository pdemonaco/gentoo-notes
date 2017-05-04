# Automatically startx if we're using tty9
case "`tty`" in
        *tty9) startx; logout ;;
esac
